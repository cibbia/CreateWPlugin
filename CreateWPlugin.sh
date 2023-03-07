#!/bin/bash

# Get the WordPress installation directory and plugin name from the user
read -p "Enter the WordPress installation directory path: " wordpress_dir
read -p "Enter the PDF Converter plugin name (no spaces): " plugin_name


# Check if the WordPress directory exists
if [ ! -d "${wordpress_dir}/wp-content" ]; then
  echo "Error: ${wordpress_dir} is not a valid WordPress directory."
  exit 1
fi

# Check if the plugin directory already exists
plugin_dir="${wordpress_dir}/wp-content/plugins/${plugin_name}"
if [ -d "$plugin_dir" ]; then
  read -p "The directory ${plugin_dir} already exists. Do you want to continue using this directory? (y/n): " choice
  if [ "$choice" != "y" ]; then
    exit 1
  fi
fi

# Create the plugin directory
sudo mkdir -p "$plugin_dir"

sudo chown $USER:$USER $plugin_dir

# Create the plugin PHP file and add the plugin header, PDF conversion functionality, and menu page
php_file="${plugin_dir}/${plugin_name}.php"
cat << EOF > "$php_file"
<?php
/**
 * Plugin Name: PDF Converter
 * Plugin URI: https://example.com/pdf-converter
 * Description: A plugin to convert PDF files to other formats.
 * Version: 1.0.0
 * Author: Your Name
 * Author URI: https://example.com
 * License: GPL-2.0+
 * License URI: https://www.gnu.org/licenses/gpl-2.0.txt
 */

// Add your PDF conversion code here
// Use libraries such as mPDF, TCPDF, or FPDF to convert PDF files

// Add the PDF Converter menu page
add_action('admin_menu', '${plugin_name}_menu');
function ${plugin_name}_menu() {
  add_menu_page(
    'PDF Converter',
    'PDF Converter',
    'manage_options',
    '${plugin_name}',
    '${plugin_name}_page',
    'dashicons-media-document',
  );
}

// Add the PDF Converter menu page content
function ${plugin_name}_page() {
  if (isset(\$_POST['convert_pdf'])) {
    // Handle PDF conversion here
    echo '<p>PDF conversion in progress...</p>';
  }
  else {
    echo '<h1>PDF Converter</h1>';
    echo '<form method="post" enctype="multipart/form-data">';
    echo '    <label for="pdf_file">Select a PDF file:</label>';
    echo '    <input type="file" name="pdf_file" id="pdf_file">';
    echo '    <input type="submit" name="convert_pdf" value="Convert to HTML">';
    echo '</form>';
  }
}
EOF

# Set the correct permissions for the plugin directory and files
sudo chmod -R 755 "$plugin_dir"

# Check if the plugin was successfully created
if [ -f "$php_file" ]; then
  echo "Success: $plugin_name plugin created in $plugin_dir."
else
  echo "Error: Failed to create $plugin_name plugin."
  exit 1
fi
