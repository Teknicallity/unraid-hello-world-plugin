<?PHP
/* HelloWorld.php: Basic example for an Unraid plugin. */

// Set document root for Unraid environment.
$docroot = $docroot ?? $_SERVER['DOCUMENT_ROOT'] ?: '/usr/local/emhttp';

// Include Unraid's GUI helper functions.
require_once "$docroot/webGui/include/Translations.php";
require_once "$docroot/webGui/include/Helpers.php";

?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Hello World</title>
</head>
<body>
  <h1>Hello, World!</h1>
  <p>Welcome to your first Unraid plugin!</p>
</body>
</html>
