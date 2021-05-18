# opf-go-precommit

This image is used to run [pre-commit][] hooks on both Python and Go
projects.

[pre-commit]: https://pre-commit.com/

## Usage

Assuming that your local repository has a valid `.pre-commit.yaml`,
you can run your hooks like this:

```
podman run -v $PWD:/opt/app-root/src --rm \
  quay.io/larsks/opf-go-precommit pre-commit run --all-files
```

## License

opf-go-precommit -- Operate First pre-commit toolchain  
Copyright (C) 2021 Operate First Team

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
