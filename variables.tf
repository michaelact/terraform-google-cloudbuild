variable "project_id" {
  type = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "The project_id variable must must be 6 to 30 lowercase letters, digits, or hyphens; it must start with a letter and cannot end with a hyphen."
  }
  description = <<-EOD
The GCP project id where the Cloud Build trigger will be installed.
EOD
}

variable "name" {
  type = string
  validation {
    condition     = can(regex("^[a-z0-9](?:[a-z0-9-]{0,62}[a-z0-9]?)$", var.name))
    error_message = "The name variable must must be 1 to 64 lowercase letters, digits, or hyphens; it must start and end with an alphanumeric character."
  }
  description = <<-EOD
The name to give to the Cloud Build trigger.
EOD
}

variable "description" {
  type        = string
  default     = ""
  description = <<-EOD
An optional description to apply to the Cloud Build trigger.
EOD
}

variable "disabled" {
  type        = bool
  default     = false
  description = <<-EOD
A flag to create/modify the Cloud Build trigger into a disabled state.
EOD
}

variable "service_account" {
  type        = string
  default     = ""
  description = <<-EOD
An optional way to override the service account used by Cloud Build. If left
empty (default), the standard Cloud Build service account for project specified
in `project_id` will be used during execution.
EOD
}

variable "tags" {
  type        = set(string)
  default     = []
  description = <<-EOD
An optional set of tags to annotate the Cloud Build trigger.
EOD
}

variable "ignored_files" {
  type = list(string)
  validation {
    condition     = var.ignored_files == null ? true : length(compact([for pattern in var.ignored_files : trimspace(pattern) if pattern != null])) == length(var.ignored_files)
    error_message = "The ignored_files list must be empty, or contain non-empty glob patterns."
  }
  default     = []
  description = <<-EOD
An optional set of file globs to ignore when determining the set of source
changes. If provided, the list of changed files will be filtered through this
list of globs, and the trigger action will proceed only if there are unfiltered
files remaining. Default is an empty list, meaning any changes in repo should
trigger the action, subject to `included_files`.
EOD
}

variable "included_files" {
  type = list(string)
  validation {
    condition     = var.included_files == null ? true : length(compact([for pattern in var.included_files : trimspace(pattern) if pattern != null])) == length(var.included_files)
    error_message = "The included_files list must be empty, or contain non-empty glob patterns."
  }
  default     = []
  description = <<-EOD
An optional set of file globs to explicitly match when determining the set of
source changes. If provided, the list of changed files will be filtered through this
list of globs, and the trigger action will proceed only if there are positive
matches. Default is an empty list, meaning any changes in repo should
trigger the action, subject to `ignored_files`.
EOD
}

variable "substitutions" {
  type = map(string)
  validation {
    condition     = length([for k, v in var.substitutions : k if can(regex("^_[A-Z0-9_]+$", k))]) == length(var.substitutions)
    error_message = "Each substitutions key must have a leading underscore, and then be followed by uppercase letters, numbers, or underscores."
  }
  default     = {}
  description = <<-EOD
A map of substitution key:value pairs that can be referenced in the build
definition. Default is empty.
EOD
}

variable "filename" {
  type        = string
  default     = "cloudbuild.yml"
  description = <<-EOD
The path, relative to repository root, to the Cloud Build YAML file. The default
configuration will declare the filename 'cloudbuild.yml'.
EOD
}

variable "local_filename" {
  type        = string
  default     = null
  description = <<-EOD
The path, relative to where terraform module are created, to the Cloud Build YAML file. The default
configuration will left it unspecified.
EOD
}

variable "dir" {
  type        = string
  default     = ""
  description = <<-EOD
The directory path, relative to repository root, where the Cloud Build run will
be executed. Default is an empty string.
EOD
}

variable "invert_regex" {
  type        = bool
  default     = false
  description = <<-EOD
If set, the tag or branch regular expressions used to match GitHub events will
be effectively inverted, and events that *do not match* the tag or branch pattern
will be executed. Default is false.
EOD
}

variable "trigger_config" {
  type = object({
    gsr = object({
      project_id   = string
      name         = string
      branch_regex = string
      tag_regex    = string
    })
    github = object({
      owner           = string
      name            = string
      branch_regex    = string
      tag_regex       = string
      is_pr_trigger   = bool
      comment_control = string
    })
    pubsub = object({
      topic                 = string
      service_account_email = string
    })
    webhook = object({
      secret = string
    })
  })
  description = <<-EOD
The trigger_config variable defines the type of trigger (GitHub, GSR, etc), and
the specific configuration options needed. The combination of fields is too
complex to validate effectively, use a scenario specific submodule which hides
this complexity!
EOD
}

variable "location" {
  type = string
  validation {
    condition     = can(regex("^(?:global|[a-z]{2,}-[a-z]{2,}[1-9][0-9]*)$", var.location))
    error_message = "The Cloud Build location must be 'global' or a valid Compute Engine region."
  }
  default     = "global"
  description = <<-EOD
Specifies the location of the Cloud Build pool to use for the triggered workload.
The default value is 'global', but any supported Cloud Build location may be used.
EOD
}
