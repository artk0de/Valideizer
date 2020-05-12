##### v 1.2.2 (**5-13-2019**)
* Added :enum check for arrays.
* Added :unique parameter for arrays.
* Time string now casts to **DateTime**.

##### v 1.2.1 (**7-11-2019**)
**Core**
* Small bug fix with unimported file in gemspec.
* Added :datetime type.
* Added :format option for time formats.
* Added *autocast* option (**true** by default) for Valideizer::Core initializer.
* Added **clean!** method for Valideizer::Core.
* Added type constraints for options (f.e. (type: :string) and (gte: 0) couldn't be put together). Raise exception when conflicts.
* Added check for conflicting rules (f.e. (datetime: "%m.%d.%Y") and (regexp: /[a-z]?/) are conflicting). Raise exception when conflicts.
* **:bool** renamed to **:boolean**.
* **:nil** renamed to **:null**

**Rails**
* Added **valideizer_render** method.
* Added multiparams passing to in-class **valideize** method.

##### v 1.1.9 (**15-8-2019**)

* Added regexp capture groups auto-substitution.

##### v 1.1.8 (**14-8-2019**)

* ActiveRecord ID check fixed.

