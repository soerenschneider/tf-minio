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
| [minio_iam_policy.policy](https://registry.terraform.io/providers/aminueza/minio/2.3.2/docs/resources/iam_policy) | resource |
| [minio_iam_service_account.user](https://registry.terraform.io/providers/aminueza/minio/2.3.2/docs/resources/iam_service_account) | resource |
| [minio_iam_user.user](https://registry.terraform.io/providers/aminueza/minio/2.3.2/docs/resources/iam_user) | resource |
| [minio_iam_user_policy_attachment.attachment](https://registry.terraform.io/providers/aminueza/minio/2.3.2/docs/resources/iam_user_policy_attachment) | resource |
| [minio_iam_policy_document.policy](https://registry.terraform.io/providers/aminueza/minio/2.3.2/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_password_store_paths"></a> [password\_store\_paths](#input\_password\_store\_paths) | Paths to write the credentials to. | `list(string)` | n/a | yes |
| <a name="input_policy_statements"></a> [policy\_statements](#input\_policy\_statements) | n/a | <pre>list(object({<br>    preset    = optional(string)<br>    actions   = optional(list(string))<br>    resources = optional(list(string))<br>    buckets   = optional(list(string))<br>  }))</pre> | n/a | yes |
| <a name="input_rotate_secret"></a> [rotate\_secret](#input\_rotate\_secret) | Rotates credentials for all users. Use with caution! | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | `{}` | no |
| <a name="input_user_name"></a> [user\_name](#input\_user\_name) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_keys"></a> [access\_keys](#output\_access\_keys) | n/a |
| <a name="output_password_store_paths"></a> [password\_store\_paths](#output\_password\_store\_paths) | n/a |
<!-- END_TF_DOCS -->