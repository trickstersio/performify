# CHANGELOG

## 1.0.0

This version is switching performify from version `0.12.0` of `dry-validation` to `dry-schema` of version `1.4` which means breaking changes:

- Because additional options are not supported by `dry-schema` (or at least I have not found this support in the source code) we were forced to drop them as well. So, from now you can't use `current_user` in your schemas by default because it's not being passed implicitly.
