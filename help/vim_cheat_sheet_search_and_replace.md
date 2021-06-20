VIM CHEAT SHEET

Search and replace

| Key            | Action                                             |
| -------------- | -------------------------------------------------- |
| -------------- | -------------------------------------------------- |
| /pattern       | search for pattern                                 |
| -------------- | -------------------------------------------------- |
| ?pattern       | search backward for pattern                        |
| -------------- | -------------------------------------------------- |
| \vpattern      | 'very magic' pattern: non-alphanumeric characters  |
|                | are interpreted as special regex symbols           |
|                | (no escaping needed)                               |
| -------------- | -------------------------------------------------- |
| n              | repeat search in same direction                    |
| -------------- | -------------------------------------------------- |
| N              | repeat search in opposite direction                |
| -------------- | -------------------------------------------------- |
| :%s/old/new/g  | replace all old with new throughout file           |
| -------------- | -------------------------------------------------- |
| :%s/old/new/gc | replace all old with new throughout file           |
| :%s/old/new/gc | with confirmations                                 |
| -------------- | -------------------------------------------------- |
| :noh[lsearch]  | remove highlighting of search matches              |
| -------------- | -------------------------------------------------- |
