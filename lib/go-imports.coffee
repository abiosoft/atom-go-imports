{BufferedProcess, CompositeDisposable} = require 'atom'

module.exports =
  config:
    path:
      title: 'goimports path'
      description: 'Set this if the goimports executable is not found within your PATH'
      type: 'string'
      default: 'goimports'

  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-text-editor', 'go-imports:process': => @process()

  deactivate: ->
    @subscriptions.dispose()

  process: ->
      buffer = atom.workspace.getActiveTextEditor()
      buffer.save() if buffer.isModified()

      @filePath = buffer.getPath()
      if (@filePath.lastIndexOf ".go") != (@filePath.length - 3)
          atom.notifications.addError "goimports only support .go files"
          return

      command = atom.config.get 'go-imports.path'
      args = ["-w", "#{@filePath}"]
      stderr = (output)=>
        @result = output
      exit = (code)=>
        if code != 0
          atom.notifications.addError @result
        else
          buffer.save()
      process = new BufferedProcess({command, args, stderr, exit})
