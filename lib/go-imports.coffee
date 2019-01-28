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
      editor = atom.workspace.getActiveTextEditor()

      if !editor.getLastCursor().getScopeDescriptor().scopes.includes("source.go")
          atom.notifications.addError "goimports only support Go files"
          return

      command = atom.config.get 'go-imports.path'
      stdout = (output)=>
        editor.buffer.setTextViaDiff(output)
      stderr = (output)=>
        atom.notifications.addError(output)
      exit = (code)=>
        if code != 0
          atom.notifications.addError(output)
      process = new BufferedProcess({command, stdout, stderr})
      process.process.stdin.setEncoding = 'utf-8'
      process.process.stdin.write(editor.getText())
      process.process.stdin.end()
