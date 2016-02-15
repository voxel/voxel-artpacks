'use strict';

const ModalDialog = require('voxel-modal-dialog');
const createSelector = require('artpacks-ui');

module.exports = (game, opts) => new APPlugin(game, opts);

module.exports.pluginInfo = {
  clientOnly: true,
  loadAfter: ['voxel-keys', 'voxel-stitch']
};

class APPlugin {
  constructor(game, opts) {
    this.game = game;
    if (!this.getArtpacks()) throw new Error('voxel-artpacks requires game.materials as voxel-texture-shader, or voxel-stitch');
    this.keys = this.game.plugins.get('voxel-keys');
    if (!this.keys) throw new Error('voxel-artpacks requires voxel-keys plugin')

    let bindKey = opts.bindKey;
    if (bindKey === undefined) {
      bindKey = (this.game.shell ? 'P' : false);
    }

    if (bindKey) {
      this.game.shell.bind('packs', bindKey);
    }

    this.dialog = new APDialog(this, this.game);
    this.enable();
  }

  enable() {
    this.keys.down.on('packs', this.onDown = this.dialog.open.bind(this.dialog));
  }

  disable() {
    if (this.onDown) this.keys.down.removeListener('packs', this.onDown);
  }

  getArtpacks() {
    if (this.game.materials && this.game.materials.artPacks) {
      return this.game.materials.artPacks;
    }

    if (this.game.plugins.get('voxel-stitch')) {
        return this.game.plugins.get('voxel-stitch').artpacks;
    }

    return undefined;
  }
}

class APDialog extends ModalDialog {
  constructor(plugin, game) {
    super(game, {
      contents: APDialog.generateContents(plugin, game),
      escapeKeys: [192, 80]});  // `, P # TODO: match close key from binding
  }

  static generateContents(plugin, game) {
    const contents = [];

    contents.push(document.createTextNode('Drag packs below to change priority, or drop a .zip to load new pack:'));

    const selector = createSelector(plugin.getArtpacks());
    selector.container.style.margin = '5px';
    contents.push(selector.container);

    // refresh chunks to apply changes TODO: automatic? voxel-drop timeout, see https://github.com/deathcap/voxel-drop/issues/1
    const refreshButton = document.createElement('button');
    refreshButton.textContent = 'Preview';
    refreshButton.style.width = '100%';
    refreshButton.addEventListener('click', (ev) => {
      const stitcher = game.plugins.get('voxel-stitch');
      if (stitcher) {
        // game-shell/voxel-stitch - disable button while stitching in progress TODO: test this more
        refreshButton.disabled = true;
        stitcher.on('addedAll', () => {
          refreshButton.disabled = false;
        });
        stitcher.stitch();
      } else {
        // reinitialize voxel-texture-shader TODO refactor
        // TODO: support game-shell/voxel-stitch
        const old_names = game.materials.names;
        game.texture_opts.game = self.game;
        const i = 0;
        game.materials = game.texture_modules[i](game.texture_opts)
        game.materials.load(old_names);

        // refresh chunks
        game.showAllChunks();
      }
    });

    contents.push(refreshButton);

    return contents;
  }
}
