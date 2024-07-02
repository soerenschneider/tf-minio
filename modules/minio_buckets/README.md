<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_minio"></a> [minio](#requirement\_minio) | 2.3.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_minio"></a> [minio](#provider\_minio) | 2.3.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [minio_ilm_policy.bucket-lifecycle-rules](https://registry.terraform.io/providers/aminueza/minio/2.3.2/docs/resources/ilm_policy) | resource |
| [minio_s3_bucket.bucket](https://registry.terraform.io/providers/aminueza/minio/2.3.2/docs/resources/s3_bucket) | resource |
| [minio_s3_bucket_versioning.bucket](https://registry.terraform.io/providers/aminueza/minio/2.3.2/docs/resources/s3_bucket_versioning) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Specifies the name of the bucket. Can not be used together with 'bucket\_prefix'. | `string` | n/a | yes |
| <a name="input_bucket_prefix"></a> [bucket\_prefix](#input\_bucket\_prefix) | Specifies the name of the bucket. Can not be used together with 'bucket\_name'. | `string` | n/a | yes |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | n/a | `bool` | `false` | no |
| <a name="input_ilm_rules"></a> [ilm\_rules](#input\_ilm\_rules) | n/a | <pre>list(object({<br>    name                               = string<br>    expiration                         = optional(string)<br>    filter                             = optional(string)<br>    noncurrent_version_expiration_days = optional(number)<br>    noncurrent_version_transition_days = optional(number)<br>  }))</pre> | `[]` | no |
| <a name="input_object_locking"></a> [object\_locking](#input\_object\_locking) | n/a | `bool` | `false` | no |
| <a name="input_public"></a> [public](#input\_public) | n/a | `bool` | `false` | no |
| <a name="input_quota"></a> [quota](#input\_quota) | Quota for the bucket in megabytes. | `number` | `0` | no |
| <a name="input_versioning"></a> [versioning](#input\_versioning) | n/a | <pre>object({<br>    enabled           = bool<br>    exclude_folders   = optional(bool, false)<br>    excluded_prefixes = optional(list(string), [])<br>  })</pre> | <pre>{<br>  "enabled": false<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_acl"></a> [acl](#output\_acl) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_quota"></a> [quota](#output\_quota) | n/a |
| <a name="output_url"></a> [url](#output\_url) | n/a |
<!-- END_TF_DOCS -->