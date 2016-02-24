require 'tempfile'
require 'childprocess'

class ApiController < ApplicationController
  def compile
    if params[:usercode].nil?
      render :json => {:error => "usercode property is required"}, :status => 500
    end
    if params[:usercode][:code].nil?
      render :json => {:error => "code property is required"}, :status => 500
    end

    #ensure Emscripten is ready
    unless File.exist?("/tmp/.emscripten")
      setup_process = ChildProcess.build('emcc')
      setup_process.environment["HOME"] = "/tmp"
      setup_process.start
      setup_process.wait
    end

    # compile here
    @sourcecode = params[:usercode][:code]
    @sourcetype = params[:usercode][:type]
    prejs_path = Rails.root.join('public', 'js', 'prejs.js')
    postjs_path = Rails.root.join('public', 'js', 'postjs.js')
    source_file = Tempfile.new(['emscripten-source', "." + @sourcetype])
    out_file = Tempfile.new(['emscripten-out', "." + 'js'])
    out_path = out_file.path
    out_file.close
    out_file.unlink

    exit_status = 1
    prog_text = ""
    stdout_text = ""
    stderr_text = ""
    build_stdout_r, build_stdout_w = IO.pipe
    build_stderr_r, build_stderr_w = IO.pipe
    begin
      source_file.write(@sourcecode)
      source_file.flush
      compile_process = ChildProcess.build('emcc', '--pre-js', prejs_path.to_s, '--post-js', postjs_path.to_s, source_file.path, '-o', out_path)
      compile_process.io.stdout = build_stdout_w
      compile_process.io.stderr = build_stderr_w
      compile_process.environment["HOME"] = "/tmp"
      compile_process.start

      build_stdout_w.close
      build_stderr_w.close

      begin
        compile_process.poll_for_exit(15)
        exit_status = compile_process.exit_code
        if exit_status == 0
          begin
            out_file = File.open(out_path, 'r')
            prog_text = out_file.read
            File.unlink(out_path)
          rescue
            exit_status = 1
          end
        end
      rescue ChildProcess::TimeoutError
        out_file = nil
        compile_process.stop
      end

      begin
        loop {stdout_text << build_stdout_r.readpartial(8192)}
      rescue EOFError
      end
      begin
        loop {stderr_text << build_stderr_r.readpartial(8192)}
      rescue EOFError
      end

    ensure
      source_file.close
      source_file.unlink
      out_file.close unless out_file.nil?
      build_stdout_r.close
      build_stderr_r.close
    end

    stderr_text["clang: warning: argument unused during compilation: '-nostdinc++'\n"] = ""

    render :json => {:result => {:exit => exit_status, :programtext => prog_text, :stdout => stdout_text, :stderr => stderr_text}}
  end

  def submit_results
  end

  def get_tests
  end
end
