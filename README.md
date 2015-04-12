# Api Sketch

api_sketch gem provides you with DSL to describe and create API documentation.

### Three main parts include
1. API definitions DSL
2. Documentation generator
3. API example responses server


## Installation

Include the gem in your Gemfile:

```ruby
gem 'api_sketch'
```

Or install it yourself as:

    $ gem install api_sketch

## Usage

Gem is bundled with the same named executable. It's supported options list is provided below.

```
api_sketch -h
Usage: /bin/api_sketch (options)
    -d, --debug                      Run in verbose mode
    -i, --input DEFINITIONS          Path to the folder with api definitions (required)
    -o, --output DOCUMENTATION       Path to the folder where generated documentation should be saved (Default is 'documentation' folder in current folder)
    -s, --server                     Run api examples server
    -p, --port PORT                  Api examples server port (Default is 3127)
    -g, --generate                   Generate documentation from provided definitions
    -v, --version                    Show version number
    -h, --help                       Show this help
```

### Documentation generation

Documentaion generation command example. Documentation is generated into documentation folder

```
$ api_sketch -g -i definitions -o documentation
```
### API example responses server

API example responses server start command example

```
$ api_sketch -s -i definitions
[2015-04-12 20:46:19] INFO  WEBrick 1.3.1
[2015-04-12 20:46:19] INFO  ruby 2.1.2 (2014-05-08) [x86_64-darwin13.0]
[2015-04-12 20:46:19] INFO  WEBrick::HTTPServer#start: pid=5874 port=3127
```
After this server is stared response examples may be accessed with this kind url `api_sketch_response_id` and `api_sketch_response_context` parameters are used to determine which response should be returned.

```
http://localhost:3127/.json?api_sketch_response_id=users/update&api_sketch_response_context=Success
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

## Definitions

Api definitions should be into directory with similar to this example. Directory may have only one file or many with groups of resources. Resurce namespace is derived from this hierachical stucrure.

```
definitions
├── places.rb
├── users
│   └── points.rb
└── users.rb
```

Definitions DSL is writen in ruby. It consists of special keywords that are used to describe API endpoint resource's request options, url, and list of possible responses.

Here is dummy example of resource definition that includes most part of DSL syntax.

```ruby
resource "Update user profile" do # Resource name
  action "update" #   action and namespace both form resource ID that should be unique. For this current case resource ID would be "users/update"
  namespace "users" # if this value is omitted that it would be derived from folders structure and file name where this defintion is placed in. So, for example if definition is placed inside users/points.rb than it's namespace is users/points.
  description "Authenticated user could update his profile fields and password" # Resource description
  path "/api/users/me.json" # Server path where this endpoint would be processed
  http_method "PUT" # http request method
  format "json" # response format

  headers do
    add "Authorization" do
      value "Token token=:token_value"
      description ":token_value - is an authorization token value"
      example { (:A..:z).to_a.shuffle[0,16].join } # example keyword accepts callable blocks or just some simple values. Callable blocks may give new value each time examples value is requested.
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
    end

    query :document do
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
        content do # array and query have special keyword for their contents
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

  # Each resource could have many responses. For exampe normal and with error
  # Especially for responses it is better to provide detailed example values as they could be used for responses examples server
  responses do
    context "Success" do # context means response name
      http_status :ok # 200

	   # parameters section's syntax it the same as for resource request parameters
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

For more detailed DSL features examples check DSL test files at spec folder.

## TODO

- Clean genrated documentation html template css, javascripts
- Add local javascript search feature at generated html docs
- Add API index page similar to [Foursquare API docs](https://developer.foursquare.com/docs/)
- Improve documentation add more examples for shared blocks
- Add more templates for example PDF, curl, some other html styles, etc. It should be configurable as api_sketch command option. This might be made as some separate extensions gem. There also could be generators for some specific framework api controllers structure.
- Put all generated pages data into docs directory. Left assets directory outside since it may clash with generated files/folders names.
- Add some huge amout to array example responses (each type of elements should be placed to response multiple times)
- API examples server also should support endpoint search by request path & http method (this is more natural to reality method)
- Deal with query body at responses (For example redirects may have query body)
- Validate HTTP method with path and action unique composition
- Add other request/response types like plaintext, etc, xml (should be supprted at generatro and server)
- Set project name somewhere in DSL or by definitions folder name (both options needed)
- Add viewable html log for this api stubs application to let mobile developers see what data and how server receives
- Add more validations to models.
- Add more specs and tests.
- Add `shared_block "shared block name"` (definition keyword) search keyword by it's to blocks. Maybe `uses_shared_block "shared block name"`. Maybe shared blocks should be placed into special directory at definitions to be loaded before all examples
- Add more complex examples autogeneration for example server. Derive values from key names. For example string "email" should have some email value as response example.

## Contributing

1. Fork it ( https://github.com/suhovius/api_sketch/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Inspirations
- [Calamum](https://github.com/malachheb/calamum)
- [Apiary](http://apiary.io/blueprint)
- [IO Docs](https://github.com/mashery/iodocs)
- [Swagger](https://developers.helloreverb.com/swagger)