
ModalDialog = require 'voxel-modal-dialog'
createSelector = require 'artpacks-ui'

module.exports = (game, opts) -> new APPlugin(game, opts)
module.exports.pluginInfo =
  clientOnly: true

class APPlugin
  constructor: (@game, opts) ->
    throw 'voxel-artpacks requires game.materials with artPacks (voxel-texture-shader)' if not @game.materials?.artPacks?
    throw 'voxel-artpacks requires game.buttons with kb-bindings' if not @game.buttons?.down?

    @dialog = new APDialog @game
    @enable()

  enable: () ->
    @game.buttons.down.on 'packs', @onDown = @dialog.open.bind(@dialog)

  disable: () ->
    @game.buttons.down.removeListener 'packs', @onDown if @onDown?

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
    refreshButton.addEventListener 'click', (ev) => @game.showAllChunks()

    contents.push refreshButton

    super game,
      contents: contents
      escapeKeys: [192, 80]  # `, P # TODO: match close key from binding
