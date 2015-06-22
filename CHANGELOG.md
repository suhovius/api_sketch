# 0.1.3 / 2015-06-22
- Add index page with search. Add search at sidebar.

# 0.1.2 / 2015-05-31

- Add `shared_block "shared block name"` (definition keyword) search keyword by it's to blocks. Keyword `use_shared_block "shared block name"` is used to find and use previously definded block. Shared blocks are be placed into special directory 'config/shared' at input folder to be loaded before all examples.
- Reorganize internal gem structure.

# 0.1.1 / 2015-05-03

- Bootstrap template: put all generated pages data into `{output_folder}/docs` directory. Left `assets` directory outside since it may clash with generated files/folders names.
- Add endpoint search by conjuction of request `path` & `http_method` for API examples server (Works like normal api server now).
- Validate HTTP uniquness of method with path, http method and action unique composition and presence.
- Add `api_sketch_response_array_elements_count` parameter for responses server. It generates responses with provided array elements counts. If array contains different type values than each type of these elements would be placed to response multiple times.

# 0.1.0 / 2015-04-12

- Add documentation
- Add API Examples server

# 0.0.1 / 2015-01-24

Initial release
