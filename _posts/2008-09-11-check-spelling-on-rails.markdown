--- 
layout: post
title: check spelling on rails
---
A few days ago I need to do spell checking for a rails project, but can't find a ready-to-use plugin, so I implemented one.

I use the<a href="http://aspell.net/"> Aspell </a>Lib to do the checking work, and ajax for editing.

First you need to install the Aspell and at lease one dictionary.

Mac:
<strong>  sudo port install aspell aspell-dict-en</strong>

Ubuntu:
<strong>  sudo apt-get install aspell libaspell-dev aspell-en</strong>

Arch:
<strong>  sudo pacman -S aspell aspell-en </strong>

And install the Aspell Ruby binding: <a href="http://github.com/fauna/raspell/tree/master">raspell</a>

<strong>    sudo gem install raspell</strong>

Add a controller:

    # app/controllers/spelling_controller.rb
    class SpellingController << ApplicationController
      def check
        render :update do |page|
          page.replace_html 'check-result', SpellingChecker.check_spell(params[:text])
        end
      end
    end

Add a SpellingChecker Class to Lib
    # lib/spelling_checker.rb
    class SpellingChecker

      def self.check_spell text
        speller = Aspell.new("en_US")
        speller.suggestion_mode = Aspell::NORMAL
        wrongs = []
        text.gsub(/[\w\']+/) do |word|
          wrongs << word unless speller.check(word)
        end
        wrongs.uniq.each do |wrong|
          text.sub!(wrong, "<span class='wrong'>#{wrong}</span>")
        end
        return text
      end

    end

in the view:
    <label for="description">Description: </label>
    <div id="check-desc" style="display:none;">
      <%=link_to_function 'Resume editing', "ttoggleChecking()" %>
      <br />
      <div id="check-result">Checking...</div>
    </div>
    <div id="edit-desc">
      <%=link_to_function 'Check spelling', "new Ajax.Updater({ success:toggleChecking()},
                                                              '/spelling/check',
                                                              {method:'get', parameters:{text:$F('ticket_description')}});" %>
      <br />
      <%= f.text_area :description, :cols => 84, :rows => 10 %>
    </div>
    <script type='text/javascript'>
      function toggleChecking() {
        $('edit-desc', 'check-desc').invoke('toggle');
      }
    </script>

This is what it looks like:

<a href="http://www.chenk85.com/wp-content/uploads/2008/09/feedbackmine.png"><img src="http://www.chenk85.com/wp-content/uploads/2008/09/feedbackmine.png" alt="" title="check_spelling1" width="500" height="167" class="aligncenter size-full wp-image-128" /></a>

<a href="http://www.chenk85.com/wp-content/uploads/2008/09/feedbackmine2.png"><img src="http://www.chenk85.com/wp-content/uploads/2008/09/feedbackmine2.png" alt="" title="checkspelling2" width="500" height="168" class="aligncenter size-full wp-image-129" /></a>

<a href="http://www.chenk85.com/wp-content/uploads/2008/09/feedbackmine3.png"><img src="http://www.chenk85.com/wp-content/uploads/2008/09/feedbackmine3.png" alt="" title="checkspelling3" width="500" height="172" class="aligncenter size-full wp-image-130" /></a>

That is it, quite sample, isn't it? I would like to make a plugin for it, but no much time recently.

Thank yawl for pointing out my grammar misstake.
