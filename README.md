# Hello World Unraid Plugin

This is a scratch plugin repo that helped me learn about Unraid plugins. It is based off of the [dynamix](https://github.com/bergware/dynamix/) and [ich777](https://github.com/ich777/intel-gpu-top/) plugins.

# Files
## PLG files
These are what Unraid uses to actually install the plugin. It is referenced by the plugin xml template that enables download through Community Applications.

## Page Files
These provide the actual display functionality for any Unraid page. The main page must be referenced by the .plg `<PLUGIN launch=[Unraid Tab]/[Page File Name]>` tag. It is recommended for the Page File Name to be in PascalCase, and it must not include the extension.

The Unraid tab can be:
* Settings
* Tools

### Plugin Page
If you want your plugin to show up, it must have a `Menu` attribute at the top. These can be 

[Page File Name].page
```php
Menu="[Section plugin should show up under eg. 'Utilities']"
Type="xmenu"
Title="[Visible name of the plugin eg. 'My Plugin X']"
Icon="[Icon full filename eg. 'myicon.png' or a Font Awesome icon name]"
Tabs="true"
---
<?PHP
......
```
> Note: the icon should be in the plugin root directory or under its images directory (`/usr/local/emhttp/plugins/<plugin-name>/images`)

Here is a list of the official Settings tab sections
* `OtherSettings` - System Settings
* `NetworkServices` - Network Services
* `UserPreferences` - User Preferences

Many plugins use the `Utilities` section name to put their plugin under "User Utilities"

The order of entries within the sections is based on the .page filename. If you want to change this, you can add `:[number]` to manually change the ordering, with mixed results.


### New Sections
If you would like to create a new section, you can add one by making another page file.

ArbitraryName.page
```php
Menu="Tools"
Title="Arbitrary Section Name"
Type="menu"
Tag="[Icon full filename eg. 'myicon.png' or a Font Awesome icon name]"
```
> Note: the icon should be in the plugin's icon directory (`/usr/local/emhttp/plugins/<plugin-name>/icons/`) and be 16x16 pixels

The order of sections is based on the .page filename, not the title in the page file.  If you want to change this, you can add `:[number]` to manually change the ordering. This is especially useful when making your own complex plugin page with many sections.


## Readme
If you create a README.md file at `/usr/local/emhttp/plugins/<plugin-name>/`, it will be used as the description under the Plugins tab. It uses markdown for formatting.

There are two common ways of doing this
1. Simply put it in the same directory as your .page files to be added to the tarball with everything else.
2. Create it from the .plg file on installation.
```xml
<FILE Name="&emhttp;/README.md">
<INLINE>
**My Plugin X**

A test plugin!
</INLINE>
</FILE>
```