meta :managed do
  accepts_list_for :installs, :default_pkg, :choose_with => :via
  accepts_list_for :provides, :default_pkg, :choose_with => :via
  accepts_list_for :service_name, :name
  accepts_list_for :cfg

  def default_pkg
    VersionOf.new name
  end

  def pkg_manager
    Babushka::PkgHelper.for_system
  end

  def chooser
    Babushka::PkgHelper.for_system.manager_key
  end

  def chooser_choices
    # TODO integrate into SystemSpec, like SystemSpec.all_systems
    [:apt, :brew, :macports, :src]
  end

  template {
    helper :packages_present? do
      installs.all? {|pkg| pkg_manager.has? pkg }
    end

    helper :add_cfg_deps do
      cfg.all? {|target|
        target_file = target.to_s
        source_file = File.dirname(source_path) / name / "#{File.basename(target_file)}.erb"
        requires(dep("#{File.basename(target_file)} for #{name}") {
          met? { babushka_config? target_file }
          before {
            shell "mkdir -p #{File.dirname(target_file)}", :sudo => !File.writable?(File.dirname(File.dirname(target_file)))
            shell "chmod o+rx #{File.dirname(target_file)}", :sudo => !File.writable?(File.dirname(target_file))
          }
          meet { render_erb source_file, :to => target_file, :sudo => !File.writable?(File.dirname(target_file)) }
          on :linux do
            after { service_name.each {|s| sudo "/etc/init.d/#{s} restart" } }
          end
        })
      }
    end

    requires pkg_manager.manager_dep
    internal_setup {
      add_cfg_deps
    }
    met? {
      if !installs.blank?
        log_ok "Not required on #{pkg_manager.manager_key}-based systems."
      else
        packages_present? and provided?
      end
    }
    before {
      pkg_manager.update_pkg_lists_if_required
    }
    meet {
      pkg_manager.install! installs
    }
  }
end