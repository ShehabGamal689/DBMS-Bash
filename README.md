# BashProject_DBMS

## Description

This project aims to develop a Database Management System (DBMS) that enables users to store and retrieve data from a hard disk. The project is built using Bash scripting and provides a Graphical user interface (GUI) for interacting with the DBMS.

## Installation

### Clone the Repository:

```

cd dbms-bash
```

### Install Zenity:

Ensure you have Zenity version 3.42.1 or higher installed. You can check your current version using:
```
zenity --version
```
If Zenity is not installed or needs an upgrade, you can do so using your distribution's package manager:

On Ubuntu:
```
sudo apt-get update
sudo apt-get install zenity
```
On CentOS:
```
sudo dnf install zenity-3.42.1
# or
sudo yum install zenity-3.42.1
```

## Usage

To run the main script, execute the dbmenu.sh script using either of the following commands:
```
bash dbmenu.sh
# or
./dbmenu.sh
```
You'll be prompted to choose actions from the menu. Each choice sources another shell file containing a function. To exit, press "Cancel" on the DB menu. "Cancel" can also act as a back button to the previous prompt.

## Data Storage

Files are organized with each feature in the DBMS having its own .sh script file. 
The root directory contains all these script files, along with a components.sh file that holds reusable functions.(As much as we could NO OOP)

## Limitations

We aim to continually improve and refine our project.
You will be surprised we aim to please XD!

## Acknowledgments
[Zenity Manual](https://help.gnome.org/users/zenity/stable/).

## Project Status
Completed Projected

### GUI Considerations

When starting this project, I considered using a GUI to provide a more user-friendly interface for managing the database engine. After conducting some research, I found several GUI tools that were potential candidates for integration:

1. **dialog**: dialog is a utility for creating text-based dialog boxes and interactive menus in the Linux terminal. It is often used to build simple user interfaces for shell scripts. It uses the ncurses library to display text-based windows with buttons, input fields, and other interactive elements.
![dialog](Images/GUI%20Examples/Dialog.jpeg)

2. **zenity**: zenity is an improvement over dialog, providing graphical user interfaces (GUIs) in the form of popup windows. It uses the GTK+ toolkit to create windows with buttons, input boxes, message boxes, and more. zenity allows you to create basic GUIs in shell scripts and is a step up from pure text-based interfaces offered by dialog.
 ![zenity](Images/GUI%20Examples/Zenity.jpeg)

3. **yad (Yet Another Dialog)**: yad is an extension of zenity and is designed to offer even more features and flexibility for creating graphical user interfaces in shell scripts. It also uses the GTK+ toolkit like zenity but provides additional capabilities, including built-in support for tables, forms, and more complex GUI elements. With yad, you can create rich, interactive interfaces with buttons, checkboxes, dropdown lists, and custom forms.

![yad](Images/GUI%20Examples/Yad.jpeg)

To summarize, the progression is from text-based interfaces (dialog) to basic graphical interfaces (zenity) and finally to more feature-rich and complex graphical interfaces (yad). Each tool offers different levels of functionality and complexity, and you can choose the one that best suits your needs when creating GUIs in bash or other shell scripts.

### Comparison of GUI Tools

| Feature                 | dialog                             | zenity                                | yad                                  |
| ----------------------- | ---------------------------------- | ------------------------------------ | ------------------------------------ |
| Availability            | Pre-installed on many Linux systems | May require installation on some systems | May require installation on some systems |
| Language Support        | Text-based interface (ncurses)     | GTK-based GUI                        | GTK-based GUI                        |
| Table Handling          | Limited or no direct support for tables | Limited support for tables           | Built-in support for tables and forms |
| Table Functionality     | N/A                                | Display tables with text-info        | Display tables with --list or --table |
| Customization Options   | Limited customization              | Some customization options           | Highly customizable with many options |
| Interactivity           | Basic user interactions (menus, forms) | Basic user interactions (message boxes, input boxes) | Rich interactivity with buttons, forms, etc. |
| Script Complexity       | Suitable for simple scripts        | Suitable for basic GUIs              | Suitable for complex GUIs and interactions |
| Learning Curve          | Easy to learn and use              | Easy to learn and use                | May require some learning for advanced features |
| Output Format           | Text-based interface               | Popup windows                        | Popup windows or embedded in terminal |
| Documentation           | Well-documented with examples       | Decent documentation available       | Documentation available but may be limited |
| HTML & CSS Support      | NO                                 | YES                                   | YES                                  |

### Tables for Zenity & Yad


1. **zenity**

![zenity](Images/GUI%20Examples/Tables%20Zenity.jpeg)

2. **yad**

![yad](Images/GUI%20Examples/Tables%20Yad.png)

As beginners in using GUIs with linux, we decided to go with **zenity** for the following reasons:

1. User-Friendly Interface: zenity provides a simple and user-friendly graphical interface with popup windows, making it ideal for beginners.

2. Straightforward Syntax: Creating basic GUIs with zenity requires minimal knowledge of command-line options, making it accessible to beginners without delving into complex scripting.

While **yad** has more advanced features and customization options, it might have a steeper learning curve for beginners. On the other hand, **dialog** provides text-based interfaces, which may be less intuitive for users accustomed to graphical interfaces.

In summary, **zenity** is an excellent choice for beginners due to its simplicity, and easy integration into Linux environments, allowing you to create basic GUIs without much complexity.
