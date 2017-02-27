# encoding: UTF-8
require 'csv'
require 'io/console'
require 'net/ssh'
require 'optparse'
# require 'pry'

# オプション確認
## パスワード一致確認回数(最大)
chk_count_max=3

params = {}

opt = OptionParser.new
opt.on('-k file_name'){|v| params[:k] = v }
opt.on('-a file_name'){|v| params[:a] = v }
opt.parse!(ARGV)

file = params[:a]
option = {
  :keys => params[:k]
}

# アカウントリスト読み込み
data = CSV.table(file, col_sep: "\s", headers: true)

data[:account].sort.uniq.each do |account|
  puts "###### User:#{account} ########"
  puts "ホスト名\tユーザ名"
  data.each do |row|
    hn = row[0]
    ac = row[1]
    if ac == account
      puts "#{hn}\t#{ac}"
    end
  end
  # 変更の実施有無確認
  print "上記のユーザのパスワードを変更しますか？(yes or no):"
  chk_change=STDIN.gets.chomp
  if chk_change != 'yes'
    next
  end

  # パスワード入力
  count = 0
  while count < chk_count_max do
    print "New Passord:"
    @pass=STDIN.noecho(&:gets).chomp
    puts ""
    print "Retype New Password:"
    @confirm_pass=STDIN.noecho(&:gets).chomp
    puts ""

    if @pass == @confirm_pass
      break
    end
    puts "入力したパスワードが違います。"
    count = count + 1
  end
  # ３回失敗したら、次のアカウトのループに移動。
  if count == chk_count_max
    puts "３回失敗したので、パスワードの変更ができませんでした。"
    next
  end
  #　パスワードを設定する。
  res = ""

  data.each do |row|
    hostname = row[0]
    user = row[1]
    if user == account
      puts "Password Settting ホスト名：#{hostname} ユーザ：#{user}"
      s = Net::SSH.start(hostname,'root',option)
      s.open_channel do |channel|
        channel.exec("passwd --stdin #{user}") do |ch,success|
          channel.on_data do |ch,data|
            res << data
          end
          channel.send_data "#{@pass}"
          channel.eof!
        end
      end
      s.loop
      puts res
    end
  end
end
