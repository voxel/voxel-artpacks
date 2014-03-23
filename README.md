# voxel-artpacks

Artpack selector dialog (voxel.js plugin)

When opened (`packs` keybinding, example: P), the dialog shows an
[artpacks-ui](https://github.com/deathcap/artpacks-ui)
and lets you reorder the [artpacks](https://github.com/deathcap/artpacks)
used for textures, sounds, etc.:

![screenshot](http://i.imgur.com/EuEGAKP.png "Screenshot")

Drag and dropping the packs changes priority (highest is listed first);
new packs can be loaded by dropping .zip files from disk. Clicking
the preview button will apply the pack changes to the game using
[voxel-texture-shader](https://github.com/deathcap/voxel-texture-shader),
and the dialog can be dismissed by clicking outside of it (as usual for
[voxel-modal-dialog](https://github.com/deathcap/voxel-modal-dialog)).


## License

MIT

