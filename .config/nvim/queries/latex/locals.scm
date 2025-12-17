((generic_command
  command: (command_name) @_name
  arg: (curly_group (_) @text.emphasis))
  (#eq? @_name "\\index"))

; HACK: this doesn't work as expected but overrides the behavior of '$' inside non-explcicit verbatim blocks such as shellblock and codeblock
((generic_environment
   begin: (begin
     name: (curly_group_text
       (text) @_name))
   (_)+ @verbatim)
 (#any-of? @_name "shellblock" "codeblock"))
