package test

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/docker"
	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/minio/minio-go/v7"
	"github.com/minio/minio-go/v7/pkg/credentials"
	"github.com/stretchr/testify/assert"
)

const (
	minioUrl   = "http://localhost:9000"
	vaultUrl   = "http://localhost:8200"
	vaultToken = "test"
)

func TestTerragrunt(t *testing.T) {
	workDir := "../envs/dev"
	dockerOpts := &docker.Options{
		WorkingDir: workDir,
		EnvVars: map[string]string{
			"COMPOSE_FILE": "docker-compose.yaml",
		},
	}

	defer docker.RunDockerCompose(t, dockerOpts, "down")
	docker.RunDockerCompose(t, dockerOpts, "up", "-d")

	waitForVault(t)
	waitForMinio(t)

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir:    workDir,
		TerraformBinary: "terragrunt",
		EnvVars: map[string]string{
			"TF_ENCRYPTION": `key_provider "pbkdf2" "mykey" {passphrase = "somekeynotverysecure"}`,
		},
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.Apply(t, terraformOptions)

	secret, err := readVaultSecret(vaultUrl, vaultToken, "secret/data/env/dev/minio/serviceaccount/bucket-1")
	assert.NoErrorf(t, err, "Could not read vault secret")
	assert.Contains(t, secret, "AWS_ACCESS_KEY_ID")
	assert.Contains(t, secret, "AWS_SECRET_ACCESS_KEY")

	err = checkBucket(strings.Replace(minioUrl, "http://", "", 1), secret["AWS_ACCESS_KEY_ID"].(string), secret["AWS_SECRET_ACCESS_KEY"].(string), "bucket-1")
	assert.NoErrorf(t, err, "Could not check bucket/bucket does not exist")
}

func readVaultSecret(vaultAddr, token, secretPath string) (map[string]interface{}, error) {
	url := fmt.Sprintf("%s/v1/%s", vaultAddr, secretPath)

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %v", err)
	}

	req.Header.Set("X-Vault-Token", token)
	client := &http.Client{
		Timeout: 1 * time.Second,
	}
	resp, err := client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("failed to send request: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("unexpected response status: %s", resp.Status)
	}
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response body: %v", err)
	}

	var responseData map[string]interface{}
	if err := json.Unmarshal(body, &responseData); err != nil {
		return nil, fmt.Errorf("failed to parse JSON response: %v", err)
	}

	data, ok := responseData["data"].(map[string]interface{})
	if !ok {
		return nil, fmt.Errorf("unexpected response structure")
	}

	secretData, ok := data["data"].(map[string]interface{})
	if !ok {
		return nil, fmt.Errorf("unexpected secret data structure")
	}

	return secretData, nil
}

func checkBucket(endpoint, accessKey, secretKey, bucketName string) error {
	// Initialize the MinIO client
	minioClient, err := minio.New(endpoint, &minio.Options{
		Creds:  credentials.NewStaticV4(accessKey, secretKey, ""),
		Secure: false, // Set to true if using HTTPS
	})
	if err != nil {
		return fmt.Errorf("failed to initialize MinIO client: %v", err)
	}

	exists, err := minioClient.BucketExists(context.Background(), bucketName)
	if err != nil {
		return fmt.Errorf("failed to check if bucket exists: %v", err)
	}

	if !exists {
		return errors.New("bucket does not exist")
	}

	return nil
}

func waitForVault(t *testing.T) {
	retry.DoWithRetry(t, "Waiting for vault service", 100, 1*time.Second, func() (string, error) {
		resp, err := http.Get(vaultUrl + "/ui/")
		if err != nil {
			return "", err
		}
		defer resp.Body.Close()

		if resp.StatusCode != 200 {
			return "", fmt.Errorf("expected HTTP status 200 but got %d", resp.StatusCode)
		}

		return "Service is available", nil
	})
}

func waitForMinio(t *testing.T) {
	retry.DoWithRetry(t, "Waiting for minio service", 100, 1*time.Second, func() (string, error) {
		resp, err := http.Get(minioUrl + "/minio/health/live")
		if err != nil {
			return "", err
		}
		defer resp.Body.Close()

		if resp.StatusCode != 200 {
			return "", fmt.Errorf("expected HTTP status 200 but got %d", resp.StatusCode)
		}

		return "Service is available", nil
	})
}
