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

For the purposes of this plugin development, I've created a share named "unraid_development" so that I have a place to store all plugins I develop. It should show up under `/mnt/user/unraid_development/` if you follow along.

You can fork this repository or clone it and upload it to your own GitHub account with the same name. I have cloned it to the previously created user share.

Change the `gitUser` entity at the top of `unraid-hello-world-plugin.plg` to your Github username so that the urls resolve correctly.

Within the cloned folder, run `./pkg_build.sh unraid-hello-world-plugin`. This will create a tarball in the archives folder and give you the md5 hash. Copy the hash and paste it in for the `md5` entity at the top of `unraid-hello-world-plugin.plg`.

Use git to add, commit, and push all changes.

In the cloned directory, run `cp unraid-hello-world-plugin.plg /boot/`

Now you can go to Unraid Plugins tab, and under "Install Plugin", select the .plg file to install it. After installation, it will be available under "Installed Plugins" and the Unraid Settings tab.

If you are looking to publish the plugin to Community Applications, take a look at the following resources:
- [Squid's guide for publishing templates](https://forums.unraid.net/topic/57181-docker-faq/#comment-566084)
- [Sycotix's video guide for publishing templates](https://forums.unraid.net/topic/101424-how-to-publish-docker-templates-to-community-applications-on-unraid/)
- [My own templates repository](https://github.com/Teknicallity/unraid-templates)
