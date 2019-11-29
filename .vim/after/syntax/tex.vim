" Syntax clusters taken from global tex.vim
syn cluster texCmdGroup			add=CommentedCode
syn cluster texFoldGroup		add=CommentedCode
syn cluster texBoldGroup		add=CommentedCode
syn cluster texItalGroup		add=CommentedCode
syn cluster texMatchGroup		add=CommentedCode
syn cluster texMatchNMGroup		add=CommentedCode
syn cluster texStyleGroup		add=CommentedCode
syn cluster texPreambleMatchGroup	add=CommentedCode
syn cluster texRefGroup			add=CommentedCode
syn cluster texPreambleMatchGroup	add=CommentedCode
syn cluster texMathMatchGroup		add=CommentedCode
syn cluster texMathZoneGroup		add=CommentedCode

syntax match CommentedCode "%\~.*" contains=@texCommentGroup
