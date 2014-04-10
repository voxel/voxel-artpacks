
ModalDialog = require 'voxel-modal-dialog'
createSelector = require 'artpacks-ui'

module.exports = (game, opts) -> new APPlugin(game, opts)
module.exports.pluginInfo =
  clientOnly: true
  loadAfter: ['voxel-keys']

class APPlugin
  constructor: (@game, opts) ->
    @getArtpacks() ? throw new Error('voxel-artpacks requires game.materials as voxel-texture-shader, or voxel-stitch')
    @keys = @game.plugins.get('voxel-keys') ? throw new Error('voxel-artpacks requires voxel-keys plugin')

    bindKey = opts.bindKey ? (if @game.shell then 'P' else false)
    if bindKey
      @game.shell.bind 'packs', bindKey

    @dialog = new APDialog @, @game
    @enable()

  enable: () ->
    @keys.down.on 'packs', @onDown = @dialog.open.bind(@dialog)

  disable: () ->
    @keys.down.removeListener 'packs', @onDown if @onDown?

  getArtpacks: () ->
    @game.materials?.artPacks ? @game.plugins?.get('voxel-stitch')?.artpacks

class APDialog extends ModalDialog
  constructor: (@plugin, @game) ->

    contents = []

    contents.push document.createTextNode 'Drag packs below to change priority, or drop a .zip to load new pack:'

    selector = createSelector @plugin.getArtpacks()
    selector.container.style.margin = '5px'
    contents.push selector.container

    # refresh chunks to apply changes TODO: automatic? voxel-drop timeout, see https://github.com/deathcap/voxel-drop/issues/1
    refreshButton = document.createElement('button')
    refreshButton.textContent = 'Preview'
    refreshButton.style.width = '100%'
    refreshButton.addEventListener 'click', (ev) =>
      stitcher = @game.plugins.get('voxel-stitch')
      if stitcher?
        # game-shell/voxel-stitch - disable button while stitching in progress TODO: test this more
        refreshButton.true = false
        stitcher.on 'addedAll', () =>
          refreshButton.disabled = false
        stitcher.stitch()
      else
        # reinitialize voxel-texture-shader TODO refactor
        # TODO: support game-shell/voxel-stitch
        old_names = @game.materials.names
        @game.texture_opts.game = self.game
        i = 0
        @game.materials = @game.texture_modules[i](@game.texture_opts)
        @game.materials.load old_names

        # refresh chunks
        @game.showAllChunks()

    contents.push refreshButton

    super game,
      contents: contents
      escapeKeys: [192, 80]  # `, P # TODO: match close key from binding
