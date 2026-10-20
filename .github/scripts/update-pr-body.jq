"Automated update of `\($name)`.",
"",
if $old.type == "github" and $new.type == "github"
   and $old.owner == $new.owner and $old.repo == $new.repo then
  "Changes: [`\($old.rev[0:7])...\($new.rev[0:7])`](https://github.com/\($new.owner)/\($new.repo)/compare/\($old.rev)...\($new.rev))"
else
  "Changes: `\($old.rev)` to `\($new.rev)`"
end
