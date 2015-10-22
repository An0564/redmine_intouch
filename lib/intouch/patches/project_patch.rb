module Intouch
  module ProjectPatch
    def self.included(base) # :nodoc:
      base.class_eval do
        unloadable if Rails.env.production?

        # noinspection RubyArgCount
        store :intouch_settings,  accessors: %w(settings_template_id assigner_groups reminder_settings telegram_settings email_settings)

        before_create :copy_settings_from_parent

        def assigner_ids
          Group.where(id: active_assigner_groups).try(:map, &:user_ids).try(:flatten).try(:uniq)
        end

        def active_assigner_groups
          settings_template ? settings_template.assigner_groups : assigner_groups
        end

        def active_reminder_settings
          settings_template ? settings_template.reminder_settings : reminder_settings
        end

        def active_telegram_settings
          settings_template ? settings_template.telegram_settings : telegram_settings
        end

        def active_email_settings
          settings_template ? settings_template.email_settings : email_settings
        end

        def active_intouch_settings
          settings_template ? settings_template.intouch_settings : intouch_settings
        end

        def settings_template
          @settings_template ||= SettingsTemplate.find_by(id: settings_template_id)
        end

        private

        def copy_settings_from_parent
          if parent.present?
            self.intouch_settings = parent.intouch_settings
          end
        end

      end
    end

  end
end
Project.send(:include, Intouch::ProjectPatch)
