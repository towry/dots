---
name: bruno
description: Use this skill when you are about to use bruno cli to run api test, bruno is postman like tool.
---

`<base-dir>` refer to `~/.claude/skills/bruno/`

# Bruno, postman like tool 

# References 

- [Bruno CLI Usage](~/.claude/skills/bruno/references/bruno-cli-usage.md) - Comprehensive guide on using Bruno CLI with various options and examples.


## Bruno collection dir

To locate the `<bruno-collection-dir>`, you can run bash command in project root:

```bash
fd -t f bruno.json
```

The dir of this `bruno.json` is the `<bruno-collection-dir>`


## Bruno basic concepts

- Collection: A collection is a group of related API requests
- Folders: A folder can be created in collection folder to organize requests, for example: `<bruno-collection-dir>/MyFolder/folder.bru`
- Request: Single request corresponds to a bru file.
- Test: You can create a test in bru file to run test on request
- Environments: environments can be store in bru file located in `environments` dir under the collection dir.

## Bruno files

Bruno manage api files in local file system, to locate the files, you can run bash `fd -t f bruno.json` to find where the files are stored. The bruno file has extension `.bru`, it's content structure is like: 

When creating new bru files, please make sure they are organize in a reasonable folder structure.

```
meta {
  name: Get Demo
  type: http
  seq: 1
}

get {
  url: http://127.0.0.1:4000/models
  body: none
  auth: inherit
}

settings {
  encodeUrl: true
  timeout: 0
}

tests {
  test("should be able to login", function () {
    const data = res.getBody();
    expect(res.getStatus()).to.equal(200);
  });
   
  test("should return json", function () {
    const data = res.getBody();
    expect(res.getBody()).to.eql({
      hello: "Bruno",
    });
  });
}
```

## Environments 

For a demo environment file under `<bruno-collection-dir>/environments/demo.bru`, the content is like:

```
vars {
  api_base: http://127.0.0.1:8000
}
vars:secret [
  secret_test
]
```

To use this env file with bruno cli, you can run with option `--env-file <bruno-collection-dir>/environments/demo.bru`

# Online doc

https://docs.usebruno.com/bru-cli/overview
