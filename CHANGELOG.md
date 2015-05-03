# 0.1.0 / 2015-05-03

- Bootstrap template: put all generated pages data into `{output_folder}/docs` directory. Left `assets` directory outside since it may clash with generated files/folders names.
- Add endpoint search by conjuction of request `path` & `http_method` for API examples server (Works like normal api server now).
- Validate HTTP uniquness of method with path, http method and action unique composition and presence.
- Add `api_sketch_response_array_elements_count` parameter for responses server. It generates responses with provided array elements counts. If array contains different type values than each type of these elements would be placed to response multiple times.

# 0.1.0 / 2015-04-12

- Add documentation
- Add API Examples server

# 0.0.1 / 2015-01-24

Initial release