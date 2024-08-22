{
  local getLines(str, newlineChar) =
    std.split(
      std.rstripChars(str, newlineChar),
      newlineChar
    ),

  local prefixLines(prefix, lines) =
    std.map(function(line) prefix + line, lines),

  local createCommentLines(str, commentChar, newlineChar) =
    local commentLines = getLines(str, newlineChar);
    prefixLines(commentChar + ' ', commentLines),

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
            local content =
              local commentLines =
                createCommentLines(
                  comment.text,
                  commentChar,
                  newlineChar,
                );

              local countIndentChars =
                std.length(line) - std.length(std.lstripChars(line, indentationChars));
              local indentation =
                line[0:countIndentChars];
              local indented =
                prefixLines(indentation, commentLines);

              std.join(newlineChar, indented);

            if comment.type == 'before'
            then content + newlineChar + line
            else if comment.type == 'after'
            then line + newlineChar + content
            else if comment.type == 'line'
            then
              assert std.length(std.findSubstr(newlineChar, comment.text)) == 0 : 'Newline character not allowed for comment of type "%s"' % comment.type;
              std.join(' ', [line, commentChar, comment.text])
            else error 'Comment type unknown: "%s"' % comment.type
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

  withComments(comments): {
    comments: comments,
  },

  withCommentsMixin(comments): {
    comments+: comments,
  },

  addComment(needle, comment, type='before'):
    self.withCommentsMixin([
      self.comment.new(needle, comment)
      + self.comment.withType(type),
    ]),

  addCommentBeforeLine(needle, comment):
    self.addComment(needle, comment, 'before'),

  addCommentAfterLine(needle, comment):
    self.addComment(needle, comment, 'after'),

  addCommentOnSameLine(needle, comment):
    self.addComment(needle, comment, 'line'),

  comment: {
    new(needle, text): {
      needle: needle,
      text: text,
      type: 'before',
    },
    withType(type): {
      type: type,
    },
    beforeLine(): self.withType('before'),
    afterLine(): self.withType('after'),
    onSameLine(): self.withType('line'),
  },
}
