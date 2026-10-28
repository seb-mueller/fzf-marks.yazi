# fzf-marks.yazi

Jump to directories bookmarked with [fzf-marks](https://github.com/urbainvaes/fzf-marks) from inside [yazi](https://github.com/sxyazi/yazi).

## Configuration

The marks file is read from `$FZF_MARKS_FILE`, the same variable fzf-marks uses.
If it is unset, it falls back to fzf-marks' default, `~/.fzf-marks`.

```sh
export FZF_MARKS_FILE="$HOME/dotfiles/data/fzf-marks"
```

The variable has to be set in the environment yazi is started from.
