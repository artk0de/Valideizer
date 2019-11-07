# Valideizer
[![Gem Version](https://badge.fury.io/rb/valideizer.svg)](https://badge.fury.io/rb/valideizer)

**Valideizer** is a very simple tool for passing parameters. Ideally for REST.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'valideizer'
```

## Usage

Create object
```ruby
 valideizer = Valideizer::Core.new
```

Add rules for named params.

```ruby
 valideizer.add_rule :a, type: :integer, gt: 0
 valideizer.add_rule :b, type: :string, length: {min: 5, max: 15}
 valideizer.add_rule :c, type: [:string, :array], nil: true
 valideizer.add_rule :d, array_type: :integer, length: 0..23
 valideizer.add_rule :e, enum: [:one, :two, :three]
```

Validate params.

```ruby
 params = {
  a: 5,
  b: "jesus",
  c: "help us",
  d: [6, 6, 6],
  e: :one,
 }
 
 valideizer.valideized? params # => true
```

Get errors or error messages.

```ruby
 params = {
  a: -1,
  b: "jesus",
  c: 42,
  d: [6, 6, 6],
  e: :one,
 }
 
 valideizer.valideized? params
 
 valideizer.errors # Printing errors
```

**Attention!** *Valideizer* works with named parameters only.

### Validation errors printing format
```ruby
[
  {:message=>"Validation error:`a` param. Should be greater than 0. Current value: `-34`."},
  {:message=>"Validation error:`b` param. Length must be 0..10. Current value: `fivesixseveneightnine`, length: 21. "},
  {:message=>"Validation error:`c` param. Should be json type. Current type: `some`. "},
  {:message=>"Validation error:`d` param. Should be array of integer type. "},
  {:message=>"Validation error:`e` param. Out of enum. Possible values [1, 2, 3]. Current value: `4`."}
]

```

## Rails 5+

*Valideizer* gem is fully adopted to work with Rails controllers. If validation callback fails then it redirects to :valideizer_callback with errors in *params*

#### 1st way

```ruby
class SampleController < ApplicationController
      include Valideizer::Rails
      
      valideizer_callback :errors_callback # Define error's callback
      
      valideize :jesus do
        valideize :a, type: :integer, gt: 0
        valideize :b, type: :string, length: {min: 5, max: 15}
        valideize :c, type: [:string, :array], nil: true
        valideize :d, array_type: :integer, length: 0..23
        valideize :e, enum: [:one, :two, :three]
      end
      #
      # GET api/jesus
      # Jesus comes from heaven
      # 
      def jesus
        # some actions
        render json: Jesus.new.to_json 
      end
      
      valideize :help_us, :please do
        valideize :a, type: :integer, lt: 666
        valideize :b, type: :string, nil: true
        valideize :c, type: :json
      end
      #
      # POST api/help_us
      # Jesus thinks about helping
      # 
      def help_us
         render json: Apocalypse.new.to_json
      end
      
      def please
        #pleeaase
      end
      
      # Define your callback with 1 parameter for errors
      def errors_callback
        errors = params[:errors]
        render json: errors, status: :bad
      end
    end
```

In your *routes.rb* 

```ruby
  Rails.application.routes.draw do
    get '/validation_errors' => 'Sample#errors_callback'
  end
```

#### 2nd way

```ruby
class SampleController < ApplicationController
      include Valideizer::Rails
      valideizer_render do |errors|
            {
              errors: errors,
              meta: {
                errors_count: errors.count,
                success: false
              }
            }
          end
      
    end
```

#### 3rd way

Or you can use *Valideizer* without callbacks, by processing validation errors manually

```ruby
    class SampleController < ApplicationController
      include Valideizer::Rails
      
      valideize :jesus do
        valideize :a, type: :integer, gt: 0
        valideize :b, type: :string, length: {min: 5, max: 15}
        valideize :c, type: [:string, :array], nil: true
        valideize :d, array_type: :integer, length: 0..23
        valideize :e, enum: [:one, :two, :three]
      end
      #
      # GET api/jesus
      # Jesus comes from heaven
      # 
      def jesus
        if valideized? params
          # some actions
        else
          render json: {status: "bed", errors: valideizer_errors}
        end
      end
      
      valideize :help_us do
        valideize :a, type: :integer, lt: 666
        valideize :b, type: :string, nil: true
        valideize :c, type: :json
      end
      #
      # POST api/help_us
      # Jesus thinks about helping
      # 
      def help_us
        if valideized? params
         # Jesus helps us on this step
        else
         render json: {status: "bed", errors: valideizer_errors}
        end
      end
    end
```

**IMPORTANT!** Use just **one** of this use-ways.

## Available options

| Option | Arguements | Description  |
|---|---|---|
| :nil | **true** / **false**   | Passing *nil* paramter if **true**    |
| :default | *   | Sets default value for parameter if it comes nil or empty   |
| :eql | * | Equals |
| :gt | Number | Greater than
| :gte | Number | Greater than or equals
| :lt | Number | Less than
| :lte | Number | Less than or equals
| :ot | Number | Other than
| :range | Range | Checks parameter's entry in range
| :enum | Array | Checks parameter's entry in enum/array
| :type | *L4 available types* | Checks parameter's type
| :custom_type | *Object* | Checks parameter's type for custom objects
| :array_type | *L4 available types* | Checks array (and array of arrays) elements types
| :length |  Range(m..n) or <br> { min: m, max: n } |  Length constraints for Arrays, Hashes and Strings
| :regexp |  / Regexp /|  Checks regular expression.
| :active_record |  :model_name or *Model* | Validates record existence for AR models. Only if parameter is ID for some AR-model.
| :format | format pattern | Validates datetime string by pattern. You could find avalaible patterns [here](https://ruby-doc.org/stdlib-2.6.4/libdoc/time/rdoc/Time.html#strptime-method).


### Available types
| Type | Description |
| ---- | ----------- |
| :integer | Integer number
| :float | Float number
| :string | String
| :bool | Boolean
| :array | Array
| :hash | Hash
| :json | JSON object
| :datetime| String with valid date or time

### Params auto-casting

If validation rule contains "type" param then corresponding value in valideized parameters will be automatically casted to nested type.

```ruby
 valideizer.valideize :a, type: :float
 valideizer.valideize :b, type: :bool
 valideizer.valideize :a, type: :json
 
params = {
  a: "44",
  b: "false",
  c: "[1,2,3]"
}
  
 
 valideizer.valideized? params
 
 params # { a: 44.0, b: false, c: [1,2,3] }
```

You also could disable parameters auto-casting by
```ruby
Valideizer::Core.new(autocast: false)
```

### Regexp params substitution

If regexp rule contains groups or named groups corresponding values will be substituted by matched groups. Please use common or named captures separately.
```ruby

group_regexp   = /(\d{1,2}.\d{1,2}.\d{4})-(\d{1,2}.\d{1,2}.\d{4})/ # Several capture groups
named_regexp   = /(?<start_date>\d{1,2}.\d{1,2}.\d{4})-(?<end_date>\d{1,2}.\d{1,2}.\d{4})/ # Named captures
single_capture = /(\d{1,2}.\d{1,2}.\d{4})-\d{1,2}.\d{1,2}.\d{4}/ # Only 1 capture group

valideizer.valideize :groups, regexp: group_regexp
valideizer.valideize :named_groups, regexp: named_regexp
valideizer.valideize :single_capture, regexp: single_capture

params = {
  groups: "23.05.1995-23.05.2105",
  named_groups: "23.05.1995-23.05.2105",
  single_capture: "23.05.1995-23.05.2105"
}

valideizer.valideized? params

params[:groups][0] # => 23.05.1995
params[:groups][1] # => 23.05.2105

params[:named_groups][:start_date] # => 23.05.1995
params[:named_groups][:end_date] # => 23.05.2105

params[:single_capture] # => 23.05.1995
```

## Change log

Please view [CHANGE_LOG](CHANGE_LOG.md).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/artk0de. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Untitled project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/untitled/blob/master/CODE_OF_CONDUCT.md).
