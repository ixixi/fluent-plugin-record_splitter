fluent-plugin-record_splitter
=====================

Output split array plugin for fluentd.

## Dependence

- td-agent v2(fluentd ~> 0.12.0)
   - fluent-plugin-record_splitter < 0.1.6
- td-agnet v3(fluentd ~> 0.14.0)
   - fluent-plugin-record_splitter >= 0.1.6

## Installation

```
gem install fluent-plugin-record_splitter
```

## Configuration

    <match pattern>
      type record_splitter
      tag foo.split
      split_key target_field
      keep_keys ["common","general"]
    </match>

If following record is passed:

```js
{'common':'c', 'general':'g', 'other':'foo', 'target_field':[ {'k1':'v1'}, {'k2':'v2'} ] }
```

then you got new records like below:

```js
{'common':'c', 'general':'g', 'k1':'v1'}
{'common':'c', 'general':'g', 'k2':'v2'}
```

another configuration

    <match pattern>
      type record_splitter
      tag foo.split
      split_key target_field
      keep_other_key true
      remove_keys ["general"]
    </match>

If following record is passed:

```js
{'common':'c', 'general':'g', 'other':'foo', 'target_field':[ {'k1':'v1'}, {'k2':'v2'} ] }
```

then you got new records like below:

```js
{'common':'c', 'other':'foo', 'k1':'v1'}
{'common':'c', 'other':'foo', 'k2':'v2'}
```

## Copyright

<table>
  <tr>
    <td>Author</td><td>Yuri Odagiri <ixixizko@gmail.com></td>
  </tr>
  <tr>
    <td>Copyright</td><td>Copyright (c) 2015- Yuri Odagiri</td>
  </tr>
  <tr>
    <td>License</td><td>MIT License</td>
  </tr>
</table>
