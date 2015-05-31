# Api Sketch

[![Gem Version](https://badge.fury.io/rb/api_sketch.svg)](http://badge.fury.io/rb/api_sketch)

---
api_sketch gem provides you with DSL to describe and create API documentation.

It consists of three main parts:

1. API definitions DSL
2. Documentation generator
3. API example responses server

---

Installation
------------

Include the gem in your Gemfile:

```ruby
gem 'api_sketch'
```

Or install it yourself as:

    $ gem install api_sketch

Usage
-----

Gem is bundled with the same named executable. It's supported options list is provided below.

```
$ api_sketch -h
Usage: /bin/api_sketch (options)
    -d, --debug                      Run in verbose mode
    -i, --input DEFINITIONS          Path to the folder with api definitions (required)
    -o, --output DOCUMENTATION       Path to the folder where generated documentation should be saved (Default is 'documentation' folder in current folder)
    -s, --server                     Run api examples server
    -p, --port PORT                  Api examples server port (Default is 3127)
    -g, --generate                   Generate documentation from provided definitions
    -n, --name PROJECT_NAME          Name of the project. (Default is derived from DEFINITIONS folder name)
    -v, --version                    Show version number
    -h, --help                       Show this help
```

### Documentation generation

Documentaion generation command example:

```
$ api_sketch -g -i definitions -o documentation
```
### API example responses server

Start API example responses server command example:

```
$ api_sketch -s -i definitions
[2015-04-12 20:46:19] INFO  WEBrick 1.3.1
[2015-04-12 20:46:19] INFO  ruby 2.1.2 (2014-05-08) [x86_64-darwin13.0]
[2015-04-12 20:46:19] INFO  WEBrick::HTTPServer#start: pid=5874 port=3127
```
After this server was started response example may be accessed with this kind url:

```
http://localhost:3127/.json?api_sketch_resource_id=users/update&api_sketch_response_context=Success&api_sketch_response_array_elements_count=1
```

```json
{
   "user":{
      "id":345,
      "email":"user44@email.com",
      "first_name":"First name 20",
      "last_name":"Last name 96",
      "country":{
         "name":"Ukraine",
         "id":"UA"
      },
      "authentications":[
         {
            "uid":"6668-5565-3835-6085-8727",
            "provider":"facebook"
         }
      ]
   }
}
```

`api_sketch_resource_id` and `api_sketch_response_context` parameters are used to determine which response should be returned. If `api_sketch_response_context` is omitted than it would take first available response.

`api_sketch_response_array_elements_count` - optional parameter that determines amount of elements in generated response arrays. Default value is 3.

Also server supports finding responses by http request method and path.

```
curl -H "Accept: application/json" -H "Content-type: application/json" -X PUT -d '{ "api_sketch_response_context" : "Success", "api_sketch_response_array_elements_count" : 3}' http://localhost:3127/api/users/me.json
{"user":{"id":509,"email":"user63@email.com", ... }}
```

Definitions
-----------

##### Folder

API definitions files should be placed into directory with structure similar to `definitions` folder in this example. Directory may have only one file or many files and folders with files. Resurce's `namespace` is derived from this hierachical structure.

`config` folder is loaded before `resources` folder. Some initial data as shared definition blocks may be placed at config folder.

```
definitions
├── config
│    └── initializers
│         └── shared_blocks.rb
│
└── resources
    ├── places.rb
    ├── users
    │   └── points.rb
    └── users.rb
```
##### DSL

Definitions DSL is writen in ruby. It consists of special keywords that are used to describe API endpoint resource's request options, url, and list of possible responses.

Here is dummy example of `resource` definition that includes most part of DSL syntax.

`action` and `namespace` both form resource ID that should be unique. For this current case resource ID would be `users/update`.

If `namespace` is omitted than it would be derived from folders structure and file name where this defintion is placed in. So, for example if definition is placed inside `users/points.rb` than it's namespace is `users/points`.

DSL provides `path`, `http_method`, `headers`, `parameters` keywords for request data definition. Parameters could be placed at `query` and `body` containers. Both of them could have `:array` or `:document` structure.

Supported attribute types are: `integer`, `string`, `float`, `boolean`, `datetime`, `timestamp`, `document`, `array`

Each attribute should have name, could have `description`, `example` value, could be `required`.

`example` keyword accepts callable blocks or just some simple values. Callable blocks may give new value each time `example_value` is requested.

Array and query attribute types have `content` keyword where their contents are placed in.

Each `resource` could have many `responses` with different `context`. For example succesful one and few with different errors. Especially for `responses` it is better to provide detailed `example` values as they could be used as responses by examples server.

Resource `parameters` section's syntax it the same as for `resource` request parameters.

```ruby
resource "Update user profile" do # Resource name
  action "update"
  namespace "users"
  description "Authenticated user could update his profile fields and password"
  path "/api/users/me.json" # Server path where this endpoint would be processed
  http_method "PUT" # http request method
  format "json" # response format

  headers do
    add "Authorization" do
      value "Token token=:token_value"
      description ":token_value - is an authorization token value"
      example { (:A..:z).to_a.shuffle[0,16].join }
      required true
    end

    add "X-Test" do
      value "Test=:perform_test"
      description ":perform_test - test boolean value"
      example true
    end
  end

  parameters do
    # parametes could be query and body
    query :document do
      string "hello_message" do
        description "some message"
      end

      integer "repeat_times" do
        description "times to repeat hello message"
      end

      integer "page" do
        description "page number"
        required false
        default 1
      end

      integer "per_page" do
        description "items per page amount"
        required false
        default 25
      end

      string "name" do
        description "place name"
        required true
      end

      float "range" do
        description "search range in km"
        required false
        example { rand(100) + rand.round(2) }
      end

      datetime "start_at" do
        description "start at datetime"
        required false
        example { Time.now.to_s }
      end

      timestamp "seconds" do
        description "seconds today"
        example { Time.now.to_i }
      end

      array "place_ids" do
        description "user's places ids"
        required false
        content do
          integer do
            description "hello number"
          end
          string do
            description "more text here"
          end
          document do
            content do
              boolean "is_it_true" do
              end
            end
          end
          document do
            description "some useless data :)"
            content do
              string "test" do
                description "test string"
              end
              document "keys" do
                content do
                  integer "sum" do
                  end
                  string "details text" do
                  end
                end
              end

            end
          end
        end
      end
    end

    body :document do
      document "user" do
        description "user's parameters fields"
        required true
        content do
          string "email" do
            description "user's email value"
          end
          string "password" do
            description "user's profile password"
          end
          string "first_name" do
            description "user's first name"
          end
          string "last_name" do
            description "user's last name"
          end
          string "country_locode" do
            example { ["US", "UA"].sample }
            description "Country location code"
          end

          document "stats" do
            content do
              timestamp "login_at" do
                description "last login timestamp"
                example { Time.now.to_i }
              end

              integer "login_count" do
                description "login count"
                example { rand(10000) }
              end

              string "rank" do
                description "users rank"
                example { ["Junior", "Middle", "Senior"].sample }
              end
            end
          end
        end
      end
    end
  end

  responses do
    context "Success" do
      http_status :ok # 200

      parameters do
        body :document do
          document "user" do
            content do
              integer "id" do
                description "User's ID"
              end
              string "email" do
                description "user's email value"
                example { "user#{rand(100)}@email.com" }
              end
              string "first_name" do
                description "user's first name"
                example { "First name #{rand(100)}" }
              end
              string "last_name" do
                description "user's last name"
                example { "Last name #{rand(100)}" }
              end
              document "country" do
                content do
                  string "name" do
                    description "Country name"
                    example { ["USA", "Ukraine", "Poland"].sample }
                  end
                  string "id" do
                    example :location_code
                    description "Country ID (Location code)"
                    example { ["US", "UA", "PL"].sample }
                  end
                end
              end
              array "authentications" do
                content do
                  document do
                    content do
                      string "uid" do
                        description "user's id at social network"
                        example { 5.times.map { 4.times.map { rand(10).to_s }.join }.join("-") }
                      end
                      string "provider" do
                        example { "facebook" }
                        description "user's social network type"
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end

    context "Failure" do
      http_status :bad_request # 400

      parameters do
        body :document do
          document "error" do
            content do
              string "message" do
                description "Error description"
                example { "Epic fail at your parameters" }
              end
            end
          end
        end
      end
    end
  end
end
```

For more detailed DSL features examples check DSL test files at `spec` and `examples` folders.

#####DSL: Shared exmples

This feature is designed to reduce definition duplications.
Here is shared block definition example. It's defintion should be placed into `config` directory.

```ruby
shared_block "place fields" do
  integer "id" do
    description "Place database ID"
  end

  string "name" do
    description "Place name"
    example { ["Cafe", "Market", "Restaurant", "Parking", "Park", "Palace", "Stadium"].sample }
  end

  float "area" do
    description "Place area in square meters"
    example { rand(100) + rand.round(2) }
  end
end
```

Shared block usage example. Keyword `use_shared_block` is available at `headers`, `parameters`, `attributes` and `responses` definitions.

```ruby
resource "Get places list" do
  action "index"
  path "/api/places.json"
  http_method "GET"
  format "json"

  responses do
    context "Success" do
      http_status :ok

      parameters do
        body :array do
          document do
            content do
              use_shared_block "place fields"
            end
          end
        end
      end
    end
  end
end
```

TODO
----

- Clean genrated documentation html template css, javascripts. Remove useless classes, html, etc.
- Add local javascript search feature at generated html docs
- Add API index page similar to [Foursquare API docs](https://developer.foursquare.com/docs/)
- Improve documentation, add more examples
- Add more documentation templates. For example PDF, curl, some other html styles, etc. It should be configurable as api_sketch command line option. This might be made as some separate extensions gem. There also could be generators for some specific framework api controllers structure scaffold generators.
- Deal with query body at responses (For example redirects may have query body)
- Add other request/response types like plaintext, xml, etc (should be supprted both at generator and server)
- Add realtime viewable page with log for this api examples server application to let client side developers see what data they have sent and how server received it
- Add more validations to models.
- Add more specs and tests.
- Add more complex example values autogeneration for API examples server. Derive values from key names. For example string "email" should have some email value as response example.
- rDoc documentation for code.

Contributing
------------

1. Fork it ( https://github.com/suhovius/api_sketch/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

Inspirations
------------
- [Calamum](https://github.com/malachheb/calamum)
- [Apiary](http://apiary.io/blueprint)
- [IO Docs](https://github.com/mashery/iodocs)
- [Swagger](https://developers.helloreverb.com/swagger)


License
-------

ApiSketch is free software, and may be redistributed under the terms specified in the MIT-LICENSE file.
