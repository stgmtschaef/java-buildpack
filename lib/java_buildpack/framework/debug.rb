# Encoding: utf-8
# Cloud Foundry Java Buildpack
# Copyright 2013 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'java_buildpack/framework'
require 'shellwords'

module JavaBuildpack::Framework

  # Encapsulates the detect, compile, and release functionality for contributing custom Java options to an application
  # at runtime.
  class Debug

    # Creates an instance, passing in an arbitrary collection of options.
    #
    # @param [Hash] context the context that is provided to the instance
    # @option context [Array<String>] :java_opts an array that Java options can be added to
    # @option context [Hash] :configuration the properties provided by the user
    def initialize(context = {})
      @app_dir = context[:app_dir]
      @java_opts = context[:java_opts]
    end

    # Always contributes debug info if the app is running in debug mode
    #
    # @return [String] returns +java-opts+ if Java options have been set by the user
    def detect
      CONTAINER_NAME
    end

    # Add the debug_opts script to the droplet
    #
    # @return [void]
    def compile
      add_debug_script
    end

    # Append the $DEBUG_OPTS environment variable to the command if it gets set.
    #
    # @return [void]
    def release
      @java_opts.concat ["$DEBUG_OPTS"]
    end

    private

      CONTAINER_NAME = 'debug'.freeze

      def add_debug_script
        FileUtils.mkdir_p(File.join(@app_dir, ".profile.d"))
        File.open(File.join(@app_dir, ".profile.d", "debug_opts.sh"), "a") do |file|
          file.puts(
            <<-DEBUG_BASH
if [ -n "$VCAP_DEBUG_MODE" ]; then
  if [ "$VCAP_DEBUG_MODE" = "run" ]; then
    export DEBUG_OPTS="#{debug_run_opts}"
  elif [ "$VCAP_DEBUG_MODE" = "suspend" ]; then
    export DEBUG_OPTS="#{debug_suspend_opts}"
  fi
fi
               DEBUG_BASH
          )
        end
      end
      
      def debug_run_opts
        "-Xdebug -Xrunjdwp:transport=dt_socket,address=$VCAP_DEBUG_PORT,server=y,suspend=n"
      end
    
      def debug_suspend_opts
        "-Xdebug -Xrunjdwp:transport=dt_socket,address=$VCAP_DEBUG_PORT,server=y,suspend=y"
      end
  end
end