---
name: python-conventions
description: Use when writing or editing any Python — scripts, CLIs, data pipelines, notebooks, tests. Declan's conventions for uv, typer/loguru/rich, typing, pandas method chaining, parallelism, and Pydantic parsing.
---

# Python conventions

Follow these on every Python change; they are non-negotiable defaults, not
suggestions.

## Tooling and style

- always use `uv` for dependency management
- always use `uv run` instead of `python3`
- always use typer for CLI, loguru for logs, and rich for print
- always prefer list comprehensions and functional style programming over for loops
- always prefer to not use try/except anywhere, in favor of failing loudly
- whenever you need to write temporary python code to run, make a `tmp`
- whenever we need to add parallelism, do it by first adding this dependency:
   uv add git+<https://github.com/vmasrani/machine_learning_helpers.git>

  (or uv add --script ... as appropriate)

  then import from mlh.parallel import pmap and call via

  res = pmap(f, arr)

  the arguments for pmap are:

  pmap(f, arr, n_jobs=-1, disable_tqdm=False, safe_mode=False, spawn=False, batch_size='auto', **kwargs):

  and the main one to consider which isn't shown is

  pmap(f, arr, prefer='threads')

  when threads are preferred over processes. NEVER do parallelism any other way unless I specifically ask you to  

- whenever you need to connect to postgres and pull/push data, use pandas and sql_alchemy
- whenever you need to write data processing pipelines in pandas, do it using this method-chaining style:

    ```python
    # Example of using helper functions and .pipe to simplify code blocks
    def reduce_raw_data(df):
        return (df
                .select(col('^data_.*$'))
                .pipe(window_data)
                .rename(lambda col: 'data_' + col[7:])
                .hstack(df.select(static.EXTENDED_IDS))
                .sort(static.EXTENDED_IDS)
        )
    def handle_duplicate_radials_first(df):
        return (
            df
            .sort(static.EXTENDED_IDS) # sort by ping number to get lowest ping number
            .group_by(static.ID_COLUMNS, maintain_order=True)
            .first()
            .sort(static.ID_COLUMNS)
        )
    def handle_duplicate_radials_max(df):
        return (
            df
            .sort(static.EXTENDED_IDS) # sort by ping number to get highest ping number
            .group_by(static.ID_COLUMNS, maintain_order=True)
            .max()
            .sort(static.ID_COLUMNS)
        )
    def handle_duplicate_radials_mean(df):
        return (
            df
            .sort(static.EXTENDED_IDS) # sort by ping number to get highest ping number
            .group_by(static.ID_COLUMNS, maintain_order=True)
            .mean()
        )

    processed_df = (read_feathers(chunk)
                .pipe(reduce_raw_data)
                .pipe(handle_duplicate_radials)
                .pipe(handle_missing_radials)
            )
    ```

  - Always use `uv add --script $scriptname package_name_1 package_name_2` for handling python scripts with dependencies.
  - Whenever writing python scripts, always add the uv shebang at the top:
        #!/usr/bin/env -S uv run --script
  - whenever you need to run temporary python code, do so by making a file called `tmp.py` and running via `uv run tmp.py`
  - Keep my functions small, "raveoli" code better than "spagetti" code.
  - ALWAYS use pathlib over os
  - Use comments sparingly, only write comments to explain anything non-standard
  - whenever you need to hardcode large strings (for sql queries, say), relegate all that code into a helper script called static.py
  - always use strong type hints on every function signature (parameters and return types) and on non-trivial local variables
  - never use `Any` (or `typing.Any`) — pick a concrete type, a `Protocol`, a `TypeVar`, or a union; if input is truly unknown, use `object` and narrow before use
  - never use `**kwargs` (or `*args` for non-variadic APIs) — list parameters explicitly so signatures are typed and self-documenting; the only exception is when implementing a decorator or wrapping a third-party API that requires it


## Pydantic for data parsing

### Use Pydantic Models Instead of `.get()` Chains

When parsing JSON/dict data, define Pydantic models instead of using repeated `.get()` calls.

### ❌ Avoid

```python
def process(data: dict):
    name = data.get('name', 'N/A')
    status = data.get('status', 'unknown')
    nested = data.get('nested', {})
    value = nested.get('value', 0)
```

### ✅ Prefer

```python
from pydantic import BaseModel, Field
class NestedData(BaseModel):
    value: int = 0
class MyData(BaseModel):
    name: str = 'N/A'
    status: str = 'unknown'
    nested: NestedData = Field(default_factory=NestedData)
def process(data: dict):
    obj = MyData.model_validate(data)
    # Use attribute access: obj.name, obj.nested.value
```

### Use `serialization_alias` for Field Renaming

When flattening nested models or renaming fields for output (e.g., DataFrames), use `serialization_alias` instead of manual dict construction.

```python
class RawData(BaseModel):
    id: str = Field(default=None, serialization_alias='raw_id')
    title: str = Field(default=None, serialization_alias='raw_title')
