{
  new(
    str,
    commentChar='#',
    newlineChar='\n',
    indentationChars=' \t',
  ): {
    str: str,
    comments: [],

    local applyComment(lines, comment) =
      std.map(
        function(line)
          local match = std.length(std.findSubstr(comment.needle, line)) != 0;
          if match
          then
            if std.length(std.findSubstr(newlineChar, comment.text)) != 0
            then
              local countIndentChars =
                std.length(line) - std.length(std.lstripChars(line, indentationChars));
              local indentation =
                line[0:countIndentChars];

              indentation
              + commentChar
              + ' '
              + std.join(
                newlineChar
                + indentation
                + commentChar
                + ' ',
                std.split(
                  std.rstripChars(comment.text, newlineChar),
                  newlineChar
                )
              )
              + newlineChar
              + line
            else std.join(' ', [line, commentChar, comment.text])
          else line,
        lines
      ),

    apply():
      local return =
        std.foldl(
          applyComment,
          self.comments,
          std.split(self.str, newlineChar)
        );

      std.join(newlineChar, return),
  },

  addComment(needle, comment): {
    comments+: [{
      needle: needle,
      text: comment,
    }],
  },
}
