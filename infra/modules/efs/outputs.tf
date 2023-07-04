# Produce outputs which can be consumed by other resources

# Output EFS file system ID
# Useful when needing to reference the file system in other resources or modules
output "efs_id" {
  description = "The ID of the EFS file system"         # Clear description of output
  value       = aws_efs_file_system.wordpress.id     # Output value derived from Wordpress EFS file system ID
}

# Output ID of the EFS Access Point for "themes" 
# Useful when wanting to mount the "themes" folder in other parts of your infrastructure
output "wordpress_themes_access_point_id" {
  description = "The ID of the EFS Access point we're using to mount the Themes folder" # Clear description of output
  value       = aws_efs_access_point.wordpress_themes.id  # Output value is the ID of the EFS Access point for Wordpress Themes
}

# Output ID of the EFS Access Point for "plugins"
# Useful when wanting to mount the "plugins" folder in other parts of your infrastructure
output "wordpress_plugins_access_point_id" {
  description = "The ID of the EFS Access point we're using to mount the Plugins folder" # Clear description of output
  value       = aws_efs_access_point.wordpress_plugins.id  # Output value is the ID of the EFS Access point for Wordpress Plugins
}

# Output KMS Key ID
# Useful when we need to reference the key for various encryption/decryption purposes
output "kms_key_id" {
  description = "Key ID of the Ecnryption key stored in KMS" # Clear description of output
  value       = aws_kms_key.wordpress.id # Output value derived from KMS Key ID for Wordpress
}
