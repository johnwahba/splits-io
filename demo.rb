require 'httparty'
require 'pry'

def main
  build_json_file unless File.exist?('all_runs.json')
  runs = JSON.parse(File.read('all_runs.json'))
  split_count = most_common_split_count(runs)
  qualifying_runs = get_qualifying_runs(runs, split_count)
  header = ['twitch_name', 'run_id', 'created_at'] + qualifying_runs[0]['segments'].count.times.map(&:to_s) + ['end']
  CSV.open("qualifying_runs.csv", "wb") do |csv|
    csv << header
    qualifying_runs.each do |run|
      row = 
        [run['runners'][0]['twitch_name'], run['id'], run['created_at']] + 
          run['segments'].map {|seg| seg['realtime_duration_ms']} + 
          [run['realtime_duration_ms']]
      csv << row
    end
  end
end

def get_qualifying_runs(runs, split_count)
  runs.select do |run| 
      run['segments'].count == split_count && 
        run['segments'].all? {|segment| segment['realtime_duration_ms'] && segment['realtime_duration_ms'] != 0 } &&
        run.dig('runners', 0, 'twitch_id')
    end
end

def most_common_split_count(runs)
  runs
    .group_by {|el| el['segments'].map {|el| el['name']}.count }
    .map {|k,v| [k,v.count]}
    .sort_by(&:last)
    .reverse[0][0]
end

def build_json_file
  puts 'Downloading all runs for category'
  page = 1
  all_runs = []
  runs = JSON.parse(HTTParty.get("https://splits.io/api/v4/categories/4346/runs\?page\=#{page}").body)['runs']
  all_runs += runs
  until runs.empty?
    runs = JSON.parse(HTTParty.get("https://splits.io/api/v4/categories/4346/runs\?page\=#{page}").body)['runs']
    all_runs += runs
    puts page
    page += 1
  end
  File.write('all_runs.json', all_runs.uniq.to_json)
end

main