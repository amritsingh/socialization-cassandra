# Socialization-Cassandra

Socialization is a Ruby Gem that allows any ActiveRecord model to `Follow`, `Like`, 'Comment' and/or `Share` any other model. Cassandra is used as a data store.

## Installation

### Rails 3/4

Add the gem to the gemfile:
`gem "socialization-cassandra"`

Run the generator:
`rails generate socialization -s`

Run:
`rake socialization:migrate`

### Rails 2.3.x Support

This gem requires Rails 3 or better. Sorry!

## Usage

### Setup

Allow a model to be followed:

    class Celebrity < ActiveRecord::Base
      ...
      acts_as_followable
      ...
    end

Allow a model to be a follower:

    class User < ActiveRecord::Base
      ...
      acts_as_follower
      ...
    end


Allow a model to be liked:

    class Movie < ActiveRecord::Base
      ...
      acts_as_likeable
      ...
    end

Allow a model to like:

    class User < ActiveRecord::Base
      ...
      acts_as_liker
      ...
    end

***


### acts_as_follower Methods

Follow something

    user.follow!(celebrity)

Stop following

    user.unfollow!(celebrity)

Toggle

    user.toggle_follow!(celebrity)

Is following?

    user.follows?(celebrity)

What items are you following (given that an Item model is followed)?

    user.followees(Item)


***


### acts_as_followable Methods

Find out if an objects follows

    celebrity.followed_by?(user)

All followers

    celebrity.followers(User)


***


### acts_as_liker Methods

Like something

    user.like!(movie)

Stop liking

    user.unlike!(movie)

Toggle

    user.toggle_like!(celebrity)

Likes?

    user.likes?(movie)

***


### acts_as_likeable Methods

Find out if an objects likes

    movie.liked_by?(user)

All likers

    movie.likers(User)

***

## Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2015-2016 Amrit Singh--  Released under the MIT license.
