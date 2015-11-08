[date: 2015-10-31]
[summary: Any content you write in this tag will be used as your article's summary on listing pages. If you don't include a summary tag, we'll take the first paragraph from the article itself.]
[tag: tag-one]
[tag: tag-two]

# This Is My First Post

If you don't include a date tag, we'll use the date that we first detected the article in your repo. Articles published in the future won't be visible until that date.

```ruby
def foo
  puts "this is an example of a fenced code block"
end
```

Mixing code and prose in the same file can be cumbersome. To make it easier, we support the `snippet` tag. These tags allow you to embed code from files stored in your `/snippets` directory.

[snippet: example.rb]

You can also include specific line number ranges from a snippet:

[snippet: example.rb:4,6]

foo
