# frozen_string_literal: true

module LightofdayWorker
    # Infrastructure to clone while yielding progress
    module StoreMonitor
      STORE_PROGRESS = {
        'STARTED'   => 15,
        'Parsing'   => 30,
        'remote'    => 70,
        'Receiving' => 85,
        'Storing' => 95,
        'Checking'  => 100,
        'FINISHED'  => 100
      }.freeze
  
      def self.starting_percent
        STORE_PROGRESS['STARTED'].to_s
      end
  
      def self.finished_percent
        STORE_PROGRESS['FINISHED'].to_s
      end
  
      def self.progress(line)
        STORE_PROGRESS[first_word_of(line)].to_s
      end
  
      def self.percent(stage)
        STORE_PROGRESS[stage].to_s
      end
  
      def self.first_word_of(line)
        line.match(/^[A-Za-z]+/).to_s
      end
    end
  end
  