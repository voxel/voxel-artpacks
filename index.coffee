
ModalDialog = require 'voxel-modal-dialog'
createSelector = require 'artpacks-ui'

module.exports = (game, opts) -> new APPlugin(game, opts)
module.exports.pluginInfo =
  clientOnly: true
  loadAfter: ['voxel-keys']

class APPlugin
  constructor: (@game, opts) ->
    throw new Error('voxel-artpacks requires game.materials with artPacks (voxel-texture-shader)') if not @game.materials?.artPacks?
    @keys = @game.plugins.get('voxel-keys') ? throw new Error('voxel-artpacks requires voxel-keys plugin')

    @dialog = new APDialog @game
    @enable()

  enable: () ->
    @keys.down.on 'packs', @onDown = @dialog.open.bind(@dialog)

  disable: () ->
    @keys.down.removeListener 'packs', @onDown if @onDown?

class APDialog extends ModalDialog
  constructor: (@game) ->

    contents = []

    contents.push document.createTextNode 'Drag packs below to change priority, or drop a .zip to load new pack:'

    selector = createSelector @game.materials.artPacks
    selector.container.style.margin = '5px'
    contents.push selector.container

    # refresh chunks to apply changes TODO: automatic? voxel-drop timeout, see https://github.com/deathcap/voxel-drop/issues/1
    refreshButton = document.createElement('button')
    refreshButton.textContent = 'Preview'
    refreshButton.style.width = '100%'
    refreshButton.addEventListener 'click', (ev) =>
      # reinitialize voxel-texture-shader TODO refactor
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
