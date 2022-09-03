# 一. ideavimrc
```cmd
    mklink C:\Users\yxu.ARCVIDEO\_ideavimrc c:\vim\.vim\.ideavimrc
```
# 二. neovim
### windows gui
```cmd
    mkdir c:\Neovim\nvim\site
    setx XDG_CONFIG_HOME "c:\Neovim"
    setx XDG_DATA_HOME "c:\Neovim"
    git clone https://github.com/allegiant/.vim.git c:\Neovim\share\nvim\.vim
    mklink c:\Neovim\nvim\init.vim c:\Neovim\share\nvim\.vim\vimrc 
    mklink c:\Neovim\nvim\ginit.vim c:\Neovim\share\nvim\.vim\ginit.vim
    mklink c:\Neovim\nvim\coc-settings.json C:\Neovim\share\nvim\.vim\coc-settings.json
    

```
### linux
```cmd
    
    git clone https://github.com/allegiant/.vim.git ~/.config/nvim
    ln -s ~/.config/nvim/vimrc ~/.config/nvim/init.vim
    

```
## 安装ctags
# 三. vim
vim配置
## 获取配置文件
```cmd
	git clone  https://github.com/allegiant/.vim.git
```
## windows 创建软链接
  ```cmd
      mklink c:\vim\.vimrc c:\vim\.vim\vimrc
 ```
## 插件安装
- vim-vue
	> 1.执行 npm i -g eslint eslint-plugin-vue
	> 2.创建 .eslintrc.js
  ```cmd
			module.exports = {
				extends: [
					// add more generic rulesets here, such as:
					// 'eslint:recommended',
					'plugin:vue/essential'
				],
				rules: {
					// override/add rules settings here, such as:
					// 'vue/no-unused-vars': 'error'
				}
			}
  ```
- vim-less
	> 1.执行 npm install -g less
