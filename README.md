# setup
Some helpful scripts I use to set up my school-issued MacBook after it's been reimaged.

Please note that this code is relatively messy!

## Package lists
You can update the list of Atom packages to install with the following command:
```bash
apm list --installed --bare | cut -d '@' -f 1 > res/packages_apm.txt
```

You may similarly generate a list of Homebrew packages:
```bash
brew list > res/packages_brew.txt
```

## License
This software was created by [Erik Boesen](https://github.com/ErikBoesen) and is provided under the [MIT License](LICENSE).
