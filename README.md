# Hello World Unraid Plugin

This is a scratch plugin repository that helped me learn about Unraid plugins. It is based on the [dynamix](https://github.com/bergware/dynamix/) and [ich777](https://github.com/ich777/intel-gpu-top/) plugins.

## Files and Structure
### PLG Files
PLG files are used by Unraid to install the plugin. They are referenced by the plugin XML template, enabling download through the Community Applications interface.

### Page Files
Page files define the user interface and functionality of any Unraid page. These files must be referenced in the `.plg` file using the `<PLUGIN launch=[Unraid Tab]/[Page File Name]>` tag.

- **Naming Conventions:** Use PascalCase for page file names, and do not include the file extension.
- **Unraid Tabs:** Supported tabs include:
  - `Settings`
  - `Tools`

#### Plugin Page
To display your plugin correctly, include a `Menu` attribute in the page file. For example:

**Example Page File:**
```php
Menu="Utilities"
Type="xmenu"
Title="My Plugin X"
Icon="myicon.png"
Tabs="true"
---
<?php
// Plugin logic goes here
?>
```

- **Icon Placement:** Icons should reside in the plugin root directory or the `images` directory (`/usr/local/emhttp/plugins/<plugin-name>/images`).

**Official Settings Tab Sections:**
- `OtherSettings` - System Settings
- `NetworkServices` - Network Services
- `UserPreferences` - User Preferences

Most plugins use the `Utilities` section to appear under "User Utilities."

**Ordering Entries:** Menu entries are ordered based on the `.page` filename. To adjust the order, append `:[number]` to the filename (e.g., `PluginName:10.page`).

#### Adding New Sections
To create a new menu section, define another page file as shown below:

**Example New Section Page File:**
```php
Menu="Tools"
Title="Custom Section"
Type="menu"
Tag="myicon.png"
```

- **Icon Requirements:** Icons must be placed in the `icons` directory (`/usr/local/emhttp/plugins/<plugin-name>/icons/`) and must be 16x16 pixels.
- **Section Ordering:** Sections are ordered by `.page` filenames. Adjust the order using the `:[number]` suffix if needed.

### README
A `README.md` file located at `/usr/local/emhttp/plugins/<plugin-name>/` provides a description for the Plugins tab. 

This file supports Markdown formatting. The first line will replace the plugin name in the .plg file `<PLUGIN name="unraid-hello-world-plugin">

#### Methods to Add a README:
1. **Direct Inclusion:** Place the README in the same directory as your `.page` files so it’s included in the tarball.
2. **Dynamic Generation:** Create the README during installation using the `.plg` file.

**Example Dynamic README Creation:**
```xml
<FILE Name="&emhttp;/README.md">
<INLINE>
**My Plugin X**

A test plugin!
</INLINE>
</FILE>
```


## Development
To develop this plugin, follow these steps:

### 1. Set Up a Development Environment
1. Create a dedicated share for plugin development. I used:

    - Share Name: unraid_development
    - Path: /mnt/user/unraid_development/
2. Clone this repository into the unraid_development share. You should upload it into your github account aswell.

### 2. Configure the PLG File
1. Open the unraid-hello-world-plugin.plg file.
2. Update the `gitUser` variable at the top to your GitHub username to ensure URLs resolve correctly:
    ```xml
    <ENTITY gitUser="your-github-username">
    ```

### 3. Build the Plugin Package
1. Navigate to the cloned directory:
    ```bash
    cd /mnt/user/unraid_development/unraid-hello-world-plugin
    ```

2. Run the [build script](/pkg_build.sh):
    ```bash
    ./pkg_build.sh
    ```

    - This creates a tarball in the archives folder.
    - The script outputs the MD5 hash, version, and optionally the version suffix to the .plg file.

    If you'd like to see a simple version of this, check out the [basic build script](/basic_build.sh)

3. Open the .plg file and replace the version and md5 value with the hash from the previous step:
    ```xml
    <ENTITY md5="your-md5-hash">
    <ENTITY version="1970-01-01">
    ```

4. Use Git to commit and push your changes:
    ```bash
    git add .
    git commit -m "Update PLG file with new MD5 hash"
    git push
    ```

### 4. Install the Plugin Locally
1. Copy the .plg file to your Unraid boot drive:
    ```bash
    cp unraid-hello-world-plugin.plg /boot/
    ```

2. Open the Unraid web interface:
    - Go to the Plugins tab.
    - Under "Install Plugin," select the .plg file.

3. Once installed, the plugin will appear under the Installed Plugins section and the Settings tab.
    
### 5. Publish to Community Applications
If you want to publish your plugin to the Community Applications interface, check out these resources:

- [Squid's guide for publishing templates](https://forums.unraid.net/topic/57181-docker-faq/#comment-566084)
- [Sycotix's video guide for publishing templates](https://forums.unraid.net/topic/101424-how-to-publish-docker-templates-to-community-applications-on-unraid/)
- [My own templates repository](https://github.com/Teknicallity/unraid-templates)