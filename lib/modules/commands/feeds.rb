module Powerbot
  module DiscordCommands
    module Feeds
      extend Discordrb::Commands::CommandContainer

      # List feeds
      command(:feeds) do |event|
        feeds = Database::Feed.where(server_id: event.server.id).all
        next 'No available feeds..' if feeds.empty?
        event.channel.send_embed(
          'Feeds available in this server:',
          Discordrb::Webhooks::Embed.new(
            description: feeds.map(&:name).join("\n"),
            footer: { text: 'use pal.sub [feed name] to sub to a feed'}
          )
        )
      end

      # Create feed
      command(:create_feed) do |event, *name|
        name = name.join ' '

        maybe_existing_feed = Database::Feed.find server_id: event.server.id, name: name
        next 'Feed already exists!' if maybe_existing_feed

        Database::Feed.create(
          server_id: event.server.id,
          channel_id: event.channel.id,
          name: name
        )

        '👌'
      end

      # Delete a feed
      command(:delete_feed) do |event, *name|
        name = name.join ' '

        maybe_existing_feed = Database::Feed.find server_id: event.server.id, name: name
        next 'Feed not found..' unless maybe_existing_feed

        maybe_existing_feed.destroy

        '👌'
      end

      # Subscribe to feed
      command(:sub) do |event, *name|
        name = name.join ' '

        maybe_existing_feed = Database::Feed.find server_id: event.server.id, name: name
        next 'Feed not found. Use `pal.feeds` for a list of feeds.' unless maybe_existing_feed

        role = maybe_existing_feed.role

        if event.user.role? role
          'You\'re already subscribed to this feed.'
        else
          event.user.add_role role
          '👌'
        end
      end

      # Unsubscribe from feed
      command(:unsub) do |event|
      end

      # Push content to a feed
      command(:push) do |event|
      end
    end
  end
end
