namespace :bootstrap do
  desc "Add a whole bunch of test info"
  task :all => :environment do
		#clear data
		User.delete_all
		Category.delete_all
		Tag.delete_all
		Tutorial.delete_all
		Section.delete_all
		Exercise.delete_all
		TemplateFile.delete_all

		#tag
		tag1 = Tag.new(:name => "testTag1")
		tag1.save(:validate => false)
		tag2 = Tag.new(:name => "testTag2")
		tag2.save(:validate => false)
		tag3 = Tag.new(:name => "testTag3")
		tag3.save(:validate => false)
		tag4 = Tag.new(:name => "testTag4")
		tag4.save(:validate => false)
		tag5 = Tag.new(:name => "testTag5")
		tag5.save(:validate => false)

		#production tags
    tag = Tag.where(:name=>'loops').first_or_create()
    tag.name='loops'
    tag.save
    tag = Tag.where(:name=>'pointers').first_or_create()
    tag.name='pointers'
    tag.save
    tag = Tag.where(:name=>'recursion').first_or_create()
    tag.name='recursion'
    tag.save
    tag = Tag.where(:name=>'arrays').first_or_create()
    tag.name='arrays'    
    tag.save
    tag = Tag.where(:name=>'struct').first_or_create()
    tag.name='struct'
    tag.save
    tag = Tag.where(:name=>'syntax').first_or_create()
    tag.name='syntax'
    tag.save

    user = User.where(:username => 'test').first_or_create()
    user.password = 'test'
    user.email='smibarber@gmail.com'
    user.save

		#category
		category1 = Category.new(:name => "C")
		category1.save(:validate => false)
		category2 = Category.new(:name => "C++")
		category2.save(:validate => false)
		category3 = Category.new(:name => "Algorithms")
		category3.save(:validate => false)
		category4 = Category.new(:name => "Data Structures")
		category4.save(:validate => false)
		category5 = Category.new(:name => "Other")
		category5.save(:validate => false)

    #category = Category.where(:name => 'C tutorials').first_or_create()
    #category.save

		#functional tutorial
    tutorial = Tutorial.where(:description => 'A first course in C', :rating => 0.0, :num_ratings => 0, :title => 'An Introduction to C',
                   :difficulty => 1).first_or_create()
    tutorial.category_id = category1.id
    tutorial.user_id = user.id
    tutorial.save
    section = Section.where(:content => 'Basic programs, loops, and printf! Oh my.', :subtitle => "First Steps in C", :index => 1, :tutorial_id => tutorial.id).first_or_create()
    section.save

    exercise1 = Exercise.where(:index => 1, :section_id => section.id, :proj_type => 'c',
                                :content => <<eos
####Hello, world!####

Let's get started with C! You'll find in the editor a template for a C program, but
it doesn't do anything yet. Type the code below just above `return 0;` in the editor
and try running the program to see what happens.

```c
printf("Hello, world!\\n");
```

eos
).first_or_create()

    template1 = TemplateFile.where(:should_compile => true, :exercise_id => exercise1.id, :file_name => "hello.c", :content => "#include <stdio.h>\n\nint main() {\n\n\treturn 0;\n}\n").first_or_create()

    outval1 = OutputValidator.where(:args=>"", :exercise_id => exercise1.id, :validator => 'if (stdout.indexOf("Hello, world!") != -1) return true; else throw "Your program didn\'t print \"Hello, world!\". Try again!\\n"').first_or_create()

    exercise2 = Exercise.where(:index => 2, :section_id => section.id, :proj_type => 'c',
                                :content => <<eos
####Your first function####

#####What is a function?#####
In C programming, all executable code resides within a function. A function is a named block of code that performs a task and then returns control to a caller. Note that other programming languages may distinguish between a "function", "subroutine", "subprogram", "procedure", or "method" -- in C, these are all functions.
A function is often executed (called) several times, from several different places, during a single execution of the program. After finishing a subroutine, the program will branch back (return) to the point after the call.
Functions are a powerful programming tool.
(WikiBooks)

#####Assignment#####

Write a function matching the prototype below that returns the sum of two integers.
Make sure the name matches exactly, or else we won't be able to test your code!

```c
int sum(int x, int y);
```

eos
).first_or_create()

    template2 = TemplateFile.where(:should_compile => true, :exercise_id => exercise2.id, :file_name => "sum.c", :content => "int sum(int x, int y) {\n\n}").first_or_create()

    test_file = TestFile.where(:file_name => "test.c", :exercise_id => exercise2.id, :content => <<eos
#include <stdio.h>
int sum(int, int);

int runTests() {
  if (sum(2, 2) == 4 &&
      sum(2, 3) == 5 &&
      sum(1, 1) == 2 &&
      sum(1000, 1) == 1001)
    return 0;
  else {
    printf("Your sum function doesn't sum! Make sure you're returning the right value\\n");
    return 1;
  }
}
eos
).first_or_create()

		#filler data for styling

		#user
		user1 = User.new(:username => "testUser1", :password_digest => "39c4169e9a1f426899c5299c1ad87aed92495834", :salt => "0.17647903004752097")
    user1.save(:validate => false)
		user2 = User.new(:username => "testUser2", :password_digest => "027f958631afee3a713a978ae87ae871c2808f29", :salt => "0.4875584976929279")
    user2.save(:validate => false)
		user3 = User.new(:username => "testUser3", :password_digest => "c436b2d1a1319f7dfcc4b07bbe9bc0c4cbec4e30", :salt => "0.21261545195084608")
    user3.save(:validate => false)
		user4 = User.new(:username => "testUser4", :password_digest => "f647bd58bc7c8c4b0765980f2fd7665676d6923b", :salt => "0.09799825425026132")
    user4.save(:validate => false)
		user5 = User.new(:username => "testUser5", :password_digest => "a9f638e6e7eaa56ee8bb3d650523dd6f0dbe5932", :salt => "0.5268194634050186")
    user5.save(:validate => false)

		#tutorial
		tutorial1 = Tutorial.new(:num_ratings => 0, :description => "Description of tutorial1 Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque rhoncus rhoncus eros, sit amet bibendum dolor eleifend ut. Sed quis mattis justo. Nam eleifend arcu ac erat sodales convallis a ac massa. Etiam ultricies, nibh sed porta rutrum, arcu nibh ultrices lorem, eu faucibus turpis sem quis elit. Vivamus non lorem sem. Donec semper risus sit amet metus varius sed sollicitudin lorem pharetra. Mauris mi dolor, dapibus ut feugiat sit amet, placerat ut metus.", :title => "testTutorial1", :difficulty => 0, :rating => 0)
		tutorial1.user = user1
		tutorial1.category = category1
		tutorial1.tags << tag1
		tutorial1.tags << tag2
		tutorial1.save(:validate => false)

		tutorial2 = Tutorial.new(:num_ratings => 0, :description => "Description of tutorial2 Nam mauris ante, tincidunt ac dictum in, luctus non nunc. Phasellus congue hendrerit dictum. Aenean porta ultrices dignissim. Nam a lectus odio. Donec et libero libero, et iaculis sapien. Suspendisse leo massa, viverra quis consectetur vitae, viverra sit amet erat. Suspendisse potenti. Maecenas porta velit non diam fringilla sit amet tempor libero feugiat. Ut eget tortor a lectus condimentum ullamcorper ac in eros. Aenean ut libero id mi feugiat pharetra.", :title => "testTutorial2", :difficulty => 0, :rating => 0)
		tutorial2.user = user1
		tutorial2.category = category1
		tutorial2.tags << tag1
		tutorial2.save(:validate => false)

		tutorial3 = Tutorial.new(:num_ratings => 0, :description => "Description of tutorial3 Nulla tortor nisl, rhoncus ac sodales nec, hendrerit suscipit massa. Duis lobortis vulputate egestas. Aenean cursus, risus ac placerat tincidunt, tortor justo vehicula erat, ut dapibus nulla libero et odio. Pellentesque ut nulla nec magna sollicitudin posuere. Aenean ornare dui ut nunc eleifend sed elementum elit molestie. Suspendisse tellus purus, tincidunt at iaculis porta, sagittis vitae erat. Maecenas nec scelerisque purus. Vestibulum id diam magna. Curabitur a neque felis, feugiat ullamcorper nisl. Maecenas et elit vel nulla pulvinar porttitor.", :title => "testTutorial3", :difficulty => 0, :rating => 0)
		tutorial3.user = user2
		tutorial3.category = category1
		tutorial3.tags << tag1
		tutorial3.tags << tag3
		tutorial3.save(:validate => false)

		tutorial4 = Tutorial.new(:num_ratings => 0, :description => "Description of tutorial4 Sed dictum, turpis et fermentum ullamcorper, urna lorem iaculis eros, eget fringilla massa felis quis justo. Nam odio erat, porttitor eu pulvinar tempus, tincidunt ut mi. Fusce rhoncus neque sit amet ante porta bibendum. In a risus nunc. Suspendisse viverra tristique molestie. Cras blandit, sem vitae sagittis mattis, nunc velit lobortis mauris, a fermentum augue purus vitae dui. Phasellus eros risus, luctus a sollicitudin vel, ullamcorper id eros. Vivamus aliquam est convallis arcu gravida consequat eu non ipsum. Phasellus sed odio sem. Quisque id tristique nibh.", :title => "testTutorial4", :difficulty => 0, :rating => 0)
		tutorial4.user = user1
		tutorial4.category = category2
		tutorial4.tags << tag1
		tutorial4.tags << tag2
		tutorial4.tags << tag3
		tutorial4.save(:validate => false)

		tutorial5 = Tutorial.new(:num_ratings => 0, :description => "Description of tutorial5 Maecenas congue odio et lacus euismod vehicula. Pellentesque et arcu lacus. Suspendisse commodo euismod enim vitae molestie. Pellentesque a felis id sem luctus aliquam. Sed iaculis condimentum ante ut tincidunt. Mauris sollicitudin orci non nibh adipiscing sit amet fermentum libero volutpat. Fusce rhoncus nisl vitae nibh pulvinar sollicitudin. Quisque elementum nibh nec tellus hendrerit vitae commodo ligula aliquet. In eget tortor vel nulla laoreet auctor vel vel justo. Duis a velit ut mi suscipit fringilla vitae mattis ante. Phasellus hendrerit neque eget metus tincidunt euismod. Suspendisse potenti. Praesent commodo porttitor lacus, et lobortis odio rutrum scelerisque. Curabitur eleifend lorem ac urna fringilla non ultrices dolor ultrices. Suspendisse et tincidunt lorem.", :title => "testTutorial5", :difficulty => 0, :rating => 0)
		tutorial5.user = user3
		tutorial5.category = category2
		tutorial5.save(:validate => false)

		tutorial6 = Tutorial.new(:num_ratings => 0, :description => "Description of tutorial6 Quisque tincidunt luctus sapien vitae pharetra. Aenean nibh dolor, ultrices vitae porttitor ac, mattis sit amet sem. Quisque facilisis fermentum elit, consectetur ultrices lacus sagittis vitae. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris tellus velit, convallis ac scelerisque non, mattis eu nisl. Aenean quis urna quam, ac aliquet erat. Aenean semper semper dignissim. Phasellus eu mauris risus, non hendrerit justo. Nulla tempus velit et justo adipiscing eu pulvinar turpis condimentum. Nullam venenatis hendrerit purus vitae viverra. Ut ac sapien eget magna faucibus blandit. Ut hendrerit aliquam ante vel tincidunt.", :title => "testTutorial6", :difficulty => 0, :rating => 0)
		tutorial6.user = user1
		tutorial6.category = category3
		tutorial6.tags << tag1
		tutorial6.save(:validate => false)

		tutorial7 = Tutorial.new(:num_ratings => 0, :description => "Description of tutorial7 Aenean dolor dui, rutrum sit amet faucibus a, congue eget massa. Integer porta leo in massa ultrices aliquam sit amet ut diam. Vivamus a tempor justo. Duis auctor ante non lectus rutrum commodo. Nam commodo iaculis elit, in aliquet ligula dignissim ac. Nulla semper sagittis ipsum adipiscing ultricies. Aliquam mattis, arcu vitae tempus feugiat, neque risus imperdiet nulla, ac placerat sapien tortor a nulla. Aenean eu augue in libero pulvinar sodales vitae consectetur tellus. Sed tincidunt ultricies neque at semper. Nam lacus eros, consequat et porta fringilla, lobortis at orci. Aliquam erat volutpat. Curabitur et nunc porta leo sodales interdum. Duis vitae consectetur orci. Mauris facilisis ligula tellus, rutrum laoreet justo. Etiam eleifend sem ut dui pulvinar vel aliquet tortor suscipit. Sed condimentum varius mollis.", :title => "testTutorial7", :difficulty => 0, :rating => 0)
		tutorial7.user = user2
		tutorial7.category = category4
		tutorial7.tags << tag2
		tutorial7.save(:validate => false)

		#section
		section11 = Section.new(:subtitle => "Test section 1 for tutorial 1", :content => "Nunc consequat auctor velit a ultrices. Aenean interdum lorem non turpis auctor non euismod magna scelerisque. Mauris metus elit, imperdiet non auctor vitae, vehicula sed lacus", :index => 1)
		section11.tutorial = tutorial1
		section11.save(:validate => false)

		section12 = Section.new(:subtitle => "Test section 2 for tutorial 1", :content => "Nulla facilisi. Curabitur pretium justo non magna tincidunt mollis. Nullam nisi leo, tempus vitae cursus lacinia, convallis ac tellus.", :index => 2)
		section12.tutorial = tutorial1
		section12.save(:validate => false)

		section13 = Section.new(:subtitle => "Test section 3 for tutorial 1", :content => "Cras accumsan quam eget arcu iaculis facilisis. Maecenas ante purus, elementum eu rutrum in, pretium ac nibh.", :index => 3)
		section13.tutorial = tutorial1
		section13.save(:validate => false)

		section14 = Section.new(:subtitle => "Test section 4 for tutorial 1", :content => "Aenean lobortis mollis sapien, non convallis nisi viverra a. Proin tincidunt laoreet bibendum. Suspendisse tellus purus, bibendum pellentesque faucibus eu, volutpat quis eros.", :index => 4)
		section14.tutorial = tutorial1
		section14.save(:validate => false)

		section15 = Section.new(:subtitle => "Test section 5 for tutorial 1", :content => "Donec in accumsan est. Mauris a nisl sit amet tortor vehicula rhoncus sit amet quis metus.", :index => 5)
		section15.tutorial = tutorial1
		section15.save(:validate => false)

		section21 = Section.new(:subtitle => "Test section 1 for tutorial 2", :content => "Aenean purus elit, adipiscing sit amet lacinia ut, ultrices id elit.", :index => 1)
		section21.tutorial = tutorial2
		section21.save(:validate => false)

		section22 = Section.new(:subtitle => "Test section 2 for tutorial 2", :content => "Pellentesque malesuada, orci quis elementum volutpat, augue ante blandit velit, ut cursus lacus sapien at lectus.", :index => 2)
		section22.tutorial = tutorial2
		section22.save(:validate => false)

		section23 = Section.new(:subtitle => "Test section 3 for tutorial 2", :content => "Nullam eget nisi eu nisl gravida rutrum. Cras eleifend pretium odio, ut mattis justo posuere sed.", :index => 3)
		section23.tutorial = tutorial2
		section23.save(:validate => false)

		section31 = Section.new(:subtitle => "Test section 1 for tutorial 3", :content => "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec tempus lorem eu lorem feugiat sollicitudin. Sed nulla metus, vehicula vel accumsan sed, posuere id metus.", :index => 1)
		section31.tutorial = tutorial3
		section31.save(:validate => false)

		section32 = Section.new(:subtitle => "Test section 2 for tutorial 3", :content => "Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Morbi sit amet est vitae quam pretium rutrum.", :index => 2)
		section32.tutorial = tutorial3
		section32.save(:validate => false)

		section41 = Section.new(:subtitle => "Test section 1 for tutorial 4", :content => "Ut vel risus est, sed volutpat nisl. Maecenas neque est, iaculis sagittis ullamcorper eget, tempor sodales velit. Donec auctor, leo a pharetra fermentum, libero libero hendrerit metus, porta interdum magna nibh eu tellus.", :index => 1)
		section41.tutorial = tutorial4
		section41.save(:validate => false)

		section51 = Section.new(:subtitle => "Test section 1 for tutorial 5", :content => "Fusce auctor pellentesque lectus. Maecenas eget suscipit eros. Sed dignissim vehicula sem quis imperdiet.", :index => 1)
		section51.tutorial = tutorial5
		section51.save(:validate => false)

		section61 = Section.new(:subtitle => "Test section 1 for tutorial 6", :content => "Sed porttitor massa quis elit fringilla tempus.", :index => 1)
		section61.tutorial = tutorial6
		section61.save(:validate => false)

		section62 = Section.new(:subtitle => "Test section 2 for tutorial 6", :content => "Aenean non neque ac velit aliquam malesuada. Nullam tempus mi vel ipsum semper id tempor augue feugiat. ", :index => 2)
		section62.tutorial = tutorial6
		section62.save(:validate => false)

		section63 = Section.new(:subtitle => "Test section 3 for tutorial 6", :content => "In dui lectus, hendrerit sed hendrerit quis, commodo ac leo. Maecenas molestie diam sit amet dui tincidunt consectetur molestie ipsum aliquam.", :index => 3)
		section63.tutorial = tutorial6
		section63.save(:validate => false)

		section71 = Section.new(:subtitle => "Test section 1 for tutorial 7", :content => "Integer sem est, blandit eget aliquam at, varius vel odio. Cras vestibulum turpis fringilla velit consectetur nec lacinia leo bibendum. In scelerisque ullamcorper ante id sollicitudin. Aliquam erat volutpat. Pellentesque suscipit porttitor dolor, eu tincidunt felis egestas id. Pellentesque vel tristique justo. Quisque non massa sem. Vivamus eleifend viverra ornare. Curabitur hendrerit lobortis elit ac pellentesque.", :index => 1)
		section71.tutorial = tutorial7
		section71.save(:validate => false)

		#exercise
		exercise111 = Exercise.new(:proj_type => 'c', :index => 1, :content => "In ligula augue, scelerisque a congue at, molestie a arcu. Nullam blandit mollis mollis. Sed et iaculis ante. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Nulla varius tortor sed ipsum suscipit ac viverra ante tempus. In interdum dapibus nulla, eget vulputate neque posuere eget. Etiam vitae justo at lacus pretium suscipit. Aenean rhoncus, leo nec ullamcorper vehicula, nibh sem dignissim quam, nec aliquet arcu lorem a leo. Morbi non quam vel nibh euismod dignissim a ultrices quam. Mauris nec felis augue. Pellentesque aliquet iaculis feugiat. In scelerisque porttitor varius.")
		exercise111.section = section11
		exercise111.save(:validate => false)


		exercise112 = Exercise.new(:proj_type => 'c', :index => 2, :content => "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed ut tincidunt ante. Morbi sed sem sapien. Morbi malesuada dapibus ligula commodo volutpat. Nullam molestie felis id erat mattis ultricies. Duis posuere, eros a semper commodo, odio lectus molestie arcu, nec lobortis dolor mauris ut neque. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Mauris tempus sapien sit amet diam mollis sit amet mollis sapien faucibus. Nullam nec justo mauris, at porttitor purus.")
		exercise112.section = section11
		exercise112.save(:validate => false)

		exercise113 = Exercise.new(:proj_type => 'c', :index => 3, :content => "Mauris viverra facilisis vulputate. Praesent quis magna ipsum. Nulla sit amet est sed leo hendrerit dignissim. Donec pulvinar, urna in ullamcorper malesuada, urna lacus cursus dolor, quis fermentum massa elit ac diam. Vivamus sed libero lectus. Nullam lacus nunc, molestie quis volutpat eu, porta mattis lorem. Integer ultrices hendrerit metus, non varius libero bibendum vel. Curabitur ut lacus ac enim tempor tristique. Aenean vel lorem dictum lacus rhoncus aliquam et sed diam. Fusce lorem ligula, semper et ultrices eu, varius at orci. Cras malesuada, turpis fringilla cursus venenatis, tortor orci suscipit sapien, id feugiat ligula ligula at arcu. Phasellus ornare pharetra magna, sit amet consectetur augue tempus cursus. Nulla facilisi. Etiam semper, libero in ullamcorper faucibus, dui lectus tincidunt felis, vel porta lacus massa eget eros. Suspendisse iaculis tincidunt libero ut aliquet.")
		exercise113.section = section11
		exercise113.save(:validate => false)

		exercise114 = Exercise.new(:proj_type => 'c', :index => 4, :content => "Nulla iaculis blandit risus, vitae commodo quam semper sed. Etiam eu ante velit. Cras dapibus metus porta tellus eleifend eget lobortis enim aliquet. Curabitur ipsum eros, condimentum sed tincidunt ut, ultricies in dui. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Vivamus molestie sapien placerat nibh mattis lobortis. Mauris augue quam, auctor et ultricies et, hendrerit eget nibh. Fusce rutrum justo non mi mollis sed mattis erat interdum. Donec eget ipsum erat. Nam eu mollis arcu. Curabitur pretium risus facilisis dolor accumsan sodales.")
		exercise114.section = section11
		exercise114.save(:validate => false)

		exercise115 = Exercise.new(:proj_type => 'c', :index => 5, :content => "Integer consequat fringilla ligula sed rutrum. Morbi non nisl in est rhoncus lobortis a quis odio. Vivamus pellentesque tempor cursus. Vestibulum lacinia tempus purus tincidunt placerat. Cras sit amet lectus orci. Aliquam imperdiet justo et nisi tempor elementum. Donec ornare elementum nulla, ac tincidunt est accumsan egestas. Nulla vulputate auctor leo, eget vehicula quam dapibus at. Ut eget ultrices eros. Donec sit amet massa turpis. In eleifend tortor vitae libero ultrices euismod. Aenean arcu metus, iaculis quis dignissim non, cursus id velit. Ut condimentum pellentesque hendrerit. Phasellus est turpis, facilisis at malesuada sed, commodo vitae nisl.")
		exercise115.section = section11
		exercise115.save(:validate => false)

		exercise121 = Exercise.new(:proj_type => 'c', :index => 1, :content => "Nam volutpat leo eu turpis egestas ut dignissim sem tincidunt. Proin facilisis gravida pellentesque. Ut nec arcu eu elit consectetur sodales. Donec semper turpis nec magna volutpat fringilla. Vivamus lacus sapien, tincidunt vel luctus ut, blandit eu libero. Sed tempor venenatis dui, eu suscipit sem aliquam sit amet. Aliquam erat volutpat. Vivamus porttitor, justo sed rutrum dignissim, massa neque fermentum nulla, ac dictum ipsum tortor blandit diam. Maecenas nunc quam, rutrum in imperdiet ut, volutpat vitae nisi. Praesent turpis turpis, convallis nec malesuada a, varius at sem. Vivamus iaculis augue id libero tempus euismod. Donec mi neque, tempus ac sagittis vitae, venenatis vitae ipsum. Ut non nisl justo, venenatis faucibus augue. Aenean ultrices massa at justo posuere in tempus ligula vulputate. Nulla facilisi.")
		exercise121.section = section12
		exercise121.save(:validate => false)

		exercise122 = Exercise.new(:proj_type => 'c', :index => 2, :content => "Ut malesuada eros ac tortor mollis dictum. Maecenas vitae fermentum lacus. Sed pulvinar mi sit amet velit volutpat egestas. Aenean fermentum condimentum lectus a cursus. Quisque rutrum mi a felis tempor eget placerat dolor cursus. Cras vestibulum malesuada ipsum nec molestie. Nam convallis pretium lacinia. Fusce augue leo, ultricies id eleifend vel, scelerisque ut felis")
		exercise122.section = section12
		exercise122.save(:validate => false)

		exercise123 = Exercise.new(:proj_type => 'c', :index => 3, :content => "Praesent tortor turpis, blandit non tincidunt quis, fermentum egestas lacus. In tortor tellus, venenatis sed fermentum id, hendrerit sit amet elit. Fusce a ligula id quam sodales sollicitudin. Morbi fermentum enim vitae magna pharetra eget accumsan mi bibendum. Donec a ullamcorper est. Ut ullamcorper varius urna, vitae iaculis justo tempus nec. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Fusce vel nunc et arcu faucibus blandit. Nunc sed odio arcu, vestibulum interdum elit. Proin et nulla risus. Integer lacinia lacinia leo, ac pulvinar magna rutrum at. Vivamus eu eros vitae metus semper accumsan. Nullam scelerisque adipiscing mauris vel elementum.")
		exercise123.section = section12
		exercise123.save(:validate => false)

		exercise131 = Exercise.new(:proj_type => 'c', :index => 1, :content => "Cras sagittis purus elit, vitae vestibulum risus. Sed eu mi at leo faucibus volutpat id eu sapien. Suspendisse tempus dolor accumsan urna dignissim rutrum. Nam sed dignissim libero. Donec posuere interdum diam, vitae pretium augue accumsan mattis. Nulla facilisi. Sed lacinia, nisi in tincidunt aliquam, magna nunc posuere nibh, et accumsan ante magna et dui. Nullam vulputate placerat lectus et faucibus. Phasellus tempus porta condimentum. Nam ac magna vitae odio pharetra ultrices eget vitae est. Phasellus varius tempor ipsum in fermentum. Etiam est turpis, convallis vel mollis fringilla, vehicula sit amet dui.")
		exercise131.section = section13
		exercise131.save(:validate => false)

		exercise141 = Exercise.new(:proj_type => 'c', :index => 1, :content => "Fusce blandit lorem fermentum risus pulvinar mattis. Nullam scelerisque tellus id tellus faucibus vestibulum. Proin elementum, mauris et feugiat dignissim, nulla dui varius nulla, nec dignissim massa nisl dignissim risus. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus in velit at orci ullamcorper suscipit. Nunc euismod ante viverra nisl molestie non fringilla arcu feugiat. Vivamus urna lorem, elementum ut porttitor id, ullamcorper sed metus. Quisque non leo arcu, non condimentum metus. Donec vitae mauris ut ipsum gravida tempus. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris egestas venenatis tincidunt. Aenean id arcu tellus. Sed non auctor nunc. Pellentesque ac lorem lectus. Morbi porttitor porttitor arcu.")
		exercise141.section = section14
		exercise141.save(:validate => false)

		exercise151 = Exercise.new(:proj_type => 'c', :index => 1, :content => "Vivamus in eros turpis, ac fringilla ipsum. Nam sollicitudin lectus a dolor molestie non elementum elit blandit. Donec tortor nulla, tristique cursus porttitor id, aliquam vel augue. Suspendisse pulvinar porta volutpat. Sed commodo lacus quis mauris sagittis id elementum metus interdum. Nulla tincidunt, mauris sed eleifend ullamcorper, sem mi malesuada magna, id adipiscing risus dolor non purus. Curabitur et mauris vehicula erat suscipit aliquam. Nam consectetur fringilla molestie.")
		exercise151.section = section15
		exercise151.save(:validate => false)

		exercise152 = Exercise.new(:proj_type => 'c', :index => 2, :content => "Donec sed enim lorem, vel commodo libero. Curabitur cursus pharetra eros, a rhoncus arcu sodales a. Nulla facilisi. Praesent blandit ornare elit eget aliquam. Aliquam erat volutpat. Sed sagittis nisi sagittis felis imperdiet porttitor dictum enim interdum. Phasellus dapibus malesuada sem, vitae rutrum sem egestas ut.")
		exercise152.section = section15
		exercise152.save(:validate => false)

		exercise153 = Exercise.new(:proj_type => 'c', :index => 3, :content => "Suspendisse et velit at purus lobortis interdum. Mauris imperdiet erat quis massa rutrum facilisis. Proin non nulla nisl. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Donec consequat mollis facilisis. Ut arcu elit, imperdiet sed accumsan id, posuere consequat dui. Donec varius magna semper augue sodales sed cursus nulla lacinia. Phasellus sed erat dolor, viverra elementum libero. Phasellus pretium mauris vitae leo varius sollicitudin.")
		exercise153.section = section15
		exercise153.save(:validate => false)

		exercise211 = Exercise.new(:proj_type => 'c', :index => 1, :content => "Curabitur risus urna, hendrerit non blandit non, faucibus et nulla. Nam pellentesque tortor velit, vitae eleifend orci. Curabitur varius, ante egestas convallis lacinia, ipsum ligula scelerisque risus, tincidunt lacinia nunc neque sit amet tellus. Cras iaculis facilisis ante, ac consectetur est aliquet et. Aliquam volutpat vulputate neque, a porttitor lectus bibendum eu. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Quisque in metus adipiscing est vehicula mollis. Etiam dapibus porta odio ac viverra. Proin in quam at magna sollicitudin sollicitudin eu non neque. In hac habitasse platea dictumst. Aenean pulvinar metus nec tellus hendrerit luctus. Morbi convallis, justo id luctus iaculis, elit neque aliquam turpis, quis vehicula massa metus eget nibh. Nullam pulvinar lobortis pretium. Morbi iaculis mollis arcu quis euismod. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Aliquam fringilla venenatis neque vitae lacinia.")
		exercise211.section = section21
		exercise211.save(:validate => false)

		exercise212 = Exercise.new(:proj_type => 'c', :index => 2, :content => "Donec lacus odio, viverra pharetra sollicitudin accumsan, facilisis id leo. Maecenas nec ligula enim, quis faucibus ligula. Quisque tempus placerat metus vel pulvinar. Vivamus tincidunt, turpis a malesuada suscipit, mauris turpis sodales augue, sit amet porta nunc neque commodo metus. Nullam at ipsum interdum leo tincidunt porta ut vel enim. Vestibulum at lectus tellus, et dignissim ante. Proin enim nunc, facilisis non egestas dictum, ullamcorper id odio. Praesent faucibus hendrerit fermentum. Praesent ut congue purus. Fusce in ornare enim. Pellentesque nec neque lorem, fermentum sodales urna.")
		exercise212.section = section21
		exercise212.save(:validate => false)

		exercise221 = Exercise.new(:proj_type => 'c', :index => 1, :content => "Curabitur eget est mi, in sollicitudin orci. Vivamus porttitor nisl sit amet urna convallis laoreet. Vestibulum ornare tincidunt quam, vitae rhoncus tellus lacinia varius. In hac habitasse platea dictumst. Etiam fringilla mauris sed nulla ornare rhoncus. Vivamus eu metus lorem. Praesent blandit leo aliquet metus sollicitudin eu hendrerit ligula molestie. Sed quam nibh, ultrices at placerat non, posuere at nisi. Vivamus fringilla sem vitae turpis tristique porttitor. Vestibulum interdum arcu sed nunc fermentum eu interdum nulla consequat. Proin pretium sem quis eros tincidunt id varius quam molestie.")
		exercise221.section = section22
		exercise221.save(:validate => false)

		exercise231 = Exercise.new(:proj_type => 'c', :index => 1, :content => "In hac habitasse platea dictumst. Donec neque odio, gravida ac vulputate et, laoreet ut elit. Quisque elementum neque sit amet quam cursus aliquet. Aliquam erat volutpat. Cras sit amet dignissim tellus. Fusce ornare dui eget neque elementum a luctus arcu aliquam. Nam volutpat urna a sem tincidunt a posuere justo ultrices. Sed at semper sapien.")
		exercise231.section = section23
		exercise231.save(:validate => false)

		exercise232 = Exercise.new(:proj_type => 'c', :index => 2, :content => "Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Integer hendrerit gravida nisl nec consectetur. Praesent eu magna est, a congue nunc. Mauris dictum sapien ut quam lacinia vitae fermentum purus gravida. Nam in nunc lectus. Phasellus eget magna ut erat adipiscing interdum id at dui. Ut quam lacus, rutrum vitae scelerisque nec, tristique at nulla. Sed ornare convallis nulla. In et leo eget sapien molestie aliquet quis vel lorem. Morbi id magna non nisi facilisis facilisis sit amet eu nulla. Aenean ullamcorper metus id nisl vestibulum mattis faucibus nulla accumsan. Quisque id eros magna. Cras in risus arcu.")
		exercise232.section = section23
		exercise232.save(:validate => false)

		exercise311 = Exercise.new(:proj_type => 'c', :index => 1, :content => "Praesent gravida adipiscing libero, a adipiscing nunc aliquet eu. Pellentesque elit sapien, tempus sit amet scelerisque at, gravida ac elit. Sed eget velit ante. Donec pretium posuere leo, sed varius turpis pellentesque nec. Sed convallis turpis vitae massa vehicula pretium. Aenean vitae risus mi, nec egestas lacus. Morbi vel felis quis libero feugiat eleifend non eget ligula. Mauris et neque lectus, sit amet posuere est. Cras ut felis nunc. Fusce nulla felis, gravida a bibendum sodales, varius a mi. Nunc varius tempor arcu quis facilisis. Aenean placerat sodales ante, non viverra lectus hendrerit a.")
		exercise311.section = section31
		exercise311.save(:validate => false)

		exercise312 = Exercise.new(:proj_type => 'c', :index => 2, :content => "Proin dapibus cursus purus, in venenatis felis adipiscing eu. Sed nec leo non lectus egestas vestibulum sed porta metus. Nullam cursus posuere risus, quis posuere tellus gravida in. Sed et diam at lacus dignissim commodo. Nulla facilisi. Proin id eros quis justo vulputate scelerisque. Nunc sapien lorem, feugiat et congue non, consectetur vitae elit. Etiam nec ligula at orci vestibulum cursus non at metus. Duis congue lacus vel dolor accumsan consequat. Proin vel arcu sapien, vel scelerisque lectus.")
		exercise312.section = section31
		exercise312.save(:validate => false)

		exercise313 = Exercise.new(:proj_type => 'c', :index => 3, :content => "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur ultricies hendrerit turpis non mollis. Donec malesuada vulputate dolor, ullamcorper aliquet turpis laoreet a. Integer et elit eget mi lobortis fringilla in ut leo. Maecenas fermentum tortor ac odio pharetra sodales. Curabitur id adipiscing diam. Duis adipiscing rutrum feugiat. Sed imperdiet adipiscing luctus. Vestibulum leo turpis, commodo quis lacinia non, rhoncus et purus. Pellentesque elementum, sem in fringilla malesuada, erat neque fringilla dui, quis sollicitudin turpis leo ut magna. Integer faucibus interdum luctus. Nulla odio lectus, ullamcorper et tincidunt nec, tincidunt ut purus.")
		exercise313.section = section31
		exercise313.save(:validate => false)

		exercise314 = Exercise.new(:proj_type => 'c', :index => 4, :content => "Nunc blandit orci sed libero vehicula porta. Morbi at fermentum enim. Pellentesque odio enim, commodo id tempus quis, condimentum quis lacus. Duis massa mi, aliquet a venenatis quis, rutrum a dolor. Sed facilisis vehicula condimentum. Sed elit tortor, ultrices at posuere a, semper vitae odio. Praesent non dui in ipsum tempus placerat. Nullam placerat lectus ac dolor luctus volutpat.")
		exercise314.section = section31
		exercise314.save(:validate => false)

		exercise321 = Exercise.new(:proj_type => 'c', :index => 1, :content => "Nulla facilisi. Nam convallis venenatis leo ac lacinia. Praesent nec metus libero. Nulla massa lacus, viverra eu feugiat vitae, varius ac leo. Etiam ac ante nisl, a interdum sem. Quisque dapibus venenatis nibh consequat rutrum. Donec accumsan, velit vel tristique aliquet, nisl ante consequat metus, sed iaculis risus diam vitae libero.")
		exercise321.section = section32
		exercise321.save(:validate => false)

		exercise322 = Exercise.new(:proj_type => 'c', :index => 2, :content => "Praesent hendrerit, odio vel vehicula gravida, urna enim feugiat odio, eu varius enim eros non est. Mauris eleifend sem quis dolor pharetra sed accumsan nisi sollicitudin. Curabitur sit amet elit feugiat sem aliquet consequat at sed nisl. Ut vel hendrerit tellus. Pellentesque arcu diam, fringilla at elementum ac, bibendum vitae lacus. Vivamus nisi urna, tristique ac venenatis vel, bibendum pulvinar velit. Vestibulum neque mi, viverra at semper quis, luctus a nibh. Vivamus vel magna id risus tincidunt commodo quis a sapien. Nulla facilisi. Integer congue consectetur justo, vitae volutpat dolor dapibus a. Aliquam nec nibh lorem, ut sagittis quam.")
		exercise322.section = section32
		exercise322.save(:validate => false)

		exercise411 = Exercise.new(:proj_type => 'c', :index => 1, :content => "Praesent rhoncus tincidunt tortor, in venenatis odio sollicitudin quis. Fusce dignissim luctus ipsum at interdum. Aenean rutrum lorem non sem tincidunt bibendum. Vivamus tempor facilisis odio, venenatis adipiscing ligula posuere at. Mauris placerat lorem a dolor iaculis id iaculis neque pretium. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Fusce id libero elit, eget malesuada nulla. Quisque sit amet metus pellentesque neque vestibulum dictum. Vestibulum ultrices ligula et lacus convallis vel luctus diam tempus.")
		exercise411.section = section41
		exercise411.save(:validate => false)

		exercise412 = Exercise.new(:proj_type => 'c', :index => 2, :content => "Curabitur nunc massa, suscipit eget hendrerit nec, varius rutrum tellus. Etiam viverra sagittis vehicula. Ut ultricies, nisl at lacinia laoreet, tellus diam cursus metus, at posuere tortor urna in leo. Duis tristique, elit sagittis vestibulum venenatis, urna turpis porta dui, nec rutrum dui erat malesuada ipsum. Praesent dapibus tristique sem eget egestas. Pellentesque eleifend arcu ac neque faucibus rutrum posuere nulla scelerisque. Nam fermentum lorem non nisl feugiat ut semper ligula posuere. Duis molestie rutrum leo, sit amet pharetra libero blandit a. Suspendisse eu elit non nisl volutpat dictum a sed neque. Pellentesque luctus tellus id odio porttitor dignissim. Nam nec mi vel purus placerat accumsan a ac mi. Donec fermentum ultricies dolor vel aliquam. Phasellus tristique molestie tellus, a porta sapien tincidunt vitae. In fringilla, sapien ac feugiat consectetur, ante ante fermentum dolor, eget sollicitudin ante purus nec massa. Mauris mollis, eros tristique commodo consectetur, nisi massa commodo est, ac lobortis orci elit id magna.")
		exercise412.section = section41
		exercise412.save(:validate => false)

		exercise413 = Exercise.new(:proj_type => 'c', :index => 3, :content => "Sed aliquam est eget turpis dapibus fermentum euismod nisi sollicitudin. Praesent interdum, libero congue egestas viverra, augue nibh aliquet metus, sed aliquam justo augue quis metus. Quisque lorem leo, iaculis eget mollis tristique, vulputate sed est. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Aliquam et lorem vel odio faucibus venenatis sed quis dui. Praesent interdum sagittis libero at varius. Donec et luctus sapien. Mauris interdum vehicula felis, eget iaculis lorem laoreet nec. Duis vitae est at arcu tempor facilisis. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae;")
		exercise413.section = section41
		exercise413.save(:validate => false)

		exercise511 = Exercise.new(:proj_type => 'c', :index => 1, :content => "Proin nisl augue, pulvinar sed malesuada at, volutpat ac sapien. Maecenas a vulputate purus. Maecenas et convallis elit. Ut nulla ante, vehicula quis fringilla eget, convallis et ligula. Mauris volutpat lectus non purus dapibus vehicula nec in nisl. Duis dolor magna, fringilla accumsan molestie id, consectetur non sapien. Integer cursus rhoncus arcu, non consectetur purus auctor in. Quisque tempor malesuada nibh, vel interdum magna porta non. Vivamus ultrices leo ornare risus convallis tincidunt. Vivamus sit amet tellus quis augue aliquam sodales nec ac massa. Vivamus lacinia fringilla tellus, ut porta tortor dapibus nec. Donec sollicitudin turpis augue.")
		exercise511.section = section51
		exercise511.save(:validate => false)

		exercise611 = Exercise.new(:proj_type => 'c', :index => 1, :content => "Nulla facilisi. Morbi nec ipsum nec est sollicitudin aliquet. Nunc cursus, leo sed rhoncus pulvinar, dolor mauris dictum sapien, sit amet facilisis augue nisl eget dui. Nunc malesuada commodo augue, vitae venenatis odio interdum in. Proin sapien mauris, malesuada sit amet volutpat vel, convallis eu risus. Integer vel nunc odio. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.")
		exercise611.section = section61
		exercise611.save(:validate => false)

		exercise612 = Exercise.new(:proj_type => 'c', :index => 2, :content => "Donec in consequat nisl. Etiam interdum, erat eget bibendum sagittis, purus lectus semper sem, vitae porttitor turpis enim eu nisi. Pellentesque lorem sem, pulvinar congue blandit non, condimentum in massa. Donec sed risus ut dui vestibulum gravida in sed ante. Maecenas vulputate, ante lacinia aliquet accumsan, dui diam vehicula justo, id hendrerit diam est id risus. Donec ultrices magna in lorem suscipit ac pellentesque eros commodo. Integer sapien nisi, tempus quis aliquam nec, interdum vel tellus. Aenean malesuada, tortor in molestie fermentum, ipsum risus adipiscing ante, vitae accumsan odio enim vitae mauris. Aliquam congue magna nulla. Sed iaculis ultrices malesuada. Vivamus in tellus sit amet nisl suscipit euismod.")
		exercise612.section = section61
		exercise612.save(:validate => false)

		exercise613 = Exercise.new(:proj_type => 'c', :index => 3, :content => "Etiam lectus arcu, tristique ut pulvinar a, commodo eu dolor. Aliquam convallis, nisl vel sodales fringilla, neque diam sollicitudin augue, eu auctor arcu felis gravida leo. Nunc tincidunt cursus ante eget vehicula. Aliquam eleifend placerat sem at sagittis. Morbi condimentum vehicula purus, ac sollicitudin metus aliquet iaculis. Pellentesque convallis velit quis lacus ullamcorper fringilla. Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
		exercise613.section = section61
		exercise613.save(:validate => false)

		exercise614 = Exercise.new(:proj_type => 'c', :index => 4, :content => "Pellentesque pulvinar elit ac arcu lobortis ac tincidunt augue mollis. Phasellus eget lacinia metus. Nulla ultricies, sapien ut gravida bibendum, justo tortor egestas lacus, in hendrerit nulla purus ac urna. Vestibulum consectetur interdum risus sed euismod. Nullam lacinia turpis et ante commodo feugiat. Suspendisse adipiscing ultrices justo iaculis blandit. Vivamus sed eleifend augue. In suscipit libero sed sapien facilisis vel commodo sapien adipiscing. Maecenas quis mi vitae augue venenatis fringilla. Phasellus purus turpis, lobortis eu dignissim sit amet, tincidunt eget sapien. Nunc tempus purus a nunc varius pellentesque. Etiam eget risus dolor, a adipiscing velit. Nunc non massa luctus tortor placerat pretium. Proin a nibh libero. Curabitur imperdiet erat ac nibh iaculis vitae vehicula purus vestibulum.")
		exercise614.section = section61
		exercise614.save(:validate => false)

		exercise615 = Exercise.new(:proj_type => 'c', :index => 5, :content => "Ut dapibus ipsum eget elit adipiscing pellentesque. Nulla vitae magna ut tellus varius consequat. Quisque in elit quam, ut imperdiet turpis. Phasellus velit arcu, venenatis vitae pretium id, porta non leo. Sed a porta tellus. Vestibulum id quam velit, aliquet posuere urna. Aliquam non odio ac metus posuere suscipit ac et enim. Nullam pharetra, lacus a porttitor lacinia, velit tellus vehicula nisl, vitae bibendum augue orci vel leo. Cras at justo ipsum. Aenean condimentum, elit vitae rutrum porttitor, odio nisi ullamcorper neque, id cursus ipsum lectus ac nisl. Maecenas id nibh augue.")
		exercise615.section = section61
		exercise615.save(:validate => false)

		exercise616 = Exercise.new(:proj_type => 'c', :index => 6, :content => "Nulla vitae nulla sit amet diam fermentum lacinia. Aenean enim nisl, pulvinar non condimentum at, adipiscing eu elit. Phasellus ornare enim non odio lacinia malesuada. Duis egestas cursus est, vitae aliquet erat porttitor vitae. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Donec sem orci, tempus nec euismod quis, congue a sem. Curabitur vel neque diam. Nulla luctus tristique nulla vestibulum iaculis. Nunc commodo, leo sit amet blandit lobortis, dui lorem laoreet nulla, mollis viverra urna nisl ac elit. Donec vehicula dolor mattis neque pretium sed cursus eros bibendum. Quisque vestibulum adipiscing ligula in posuere. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.")
		exercise616.section = section61
		exercise616.save(:validate => false)

		exercise621 = Exercise.new(:proj_type => 'c', :index => 1, :content => "Vestibulum blandit porttitor nisi sed sollicitudin. Maecenas sagittis leo non neque aliquam non placerat eros iaculis. Vivamus gravida vestibulum pellentesque. Maecenas nunc odio, mollis id tincidunt vel, volutpat non tellus. Integer quis vehicula libero. Nunc in orci eget orci scelerisque auctor hendrerit et dolor. Proin sed tortor nunc. Nullam at dui mauris. Vivamus ac tincidunt nibh. Curabitur congue, libero in imperdiet fermentum, arcu urna feugiat augue, rhoncus tincidunt lorem elit in odio. Quisque lobortis scelerisque luctus. Quisque velit libero, sagittis sit amet euismod nec, egestas vel diam. Etiam placerat neque vitae neque blandit posuere. Vestibulum non quam nisi.")
		exercise621.section = section62
		exercise621.save(:validate => false)

		exercise631 = Exercise.new(:proj_type => 'c', :index => 1, :content => "Nulla sit amet turpis turpis. Ut ut turpis quis urna tincidunt dictum. Quisque at mauris lorem. Ut pellentesque luctus nulla sit amet suscipit. Cras non dolor sit amet tellus molestie aliquet. Proin non tincidunt mi. Curabitur in nunc nisi. Donec sit amet nunc risus, at pharetra nibh. Cras semper aliquet turpis non egestas. Donec blandit placerat tortor in condimentum. Nam at diam sit amet lacus dictum feugiat. Morbi libero enim, auctor ut tempor eu, gravida in eros. Morbi tellus nisl, porta eget placerat eu, sagittis quis libero. Sed nec iaculis lacus. Nullam mollis elementum quam, sed aliquam massa faucibus vitae.")
		exercise631.section = section63
		exercise631.save(:validate => false)

		exercise632 = Exercise.new(:proj_type => 'c', :index => 2, :content => "Aliquam consectetur tincidunt euismod. Sed eu odio ut sapien tempus scelerisque. Nullam tempor placerat metus et blandit. Donec posuere, dui placerat tincidunt viverra, felis velit sollicitudin nisl, at bibendum orci sem in risus. Proin mollis tempus tempor. Nam iaculis ultricies ante, eu pellentesque sem euismod lacinia. Ut placerat, nulla sit amet semper aliquet, nisl ante mollis urna, quis aliquam nisl sapien consectetur purus. Nullam sed tellus leo, eget dapibus elit. Aliquam vitae mollis tortor. Vestibulum tempor feugiat mi, sit amet sagittis lectus dignissim sed.")
		exercise632.section = section63
		exercise632.save(:validate => false)

		exercise711 = Exercise.new(:proj_type => 'c', :index => 1, :content => "Etiam facilisis urna quis orci ultrices euismod. Etiam vitae lorem porta enim faucibus eleifend. Etiam pretium tincidunt risus, eu auctor ipsum porttitor et. Aliquam non nisi velit. Integer tempus blandit dapibus. Aenean venenatis rutrum facilisis. Etiam eget libero et nunc ultrices suscipit. Vivamus pretium diam at nibh aliquam tempor. Vivamus sagittis, lorem nec consectetur vestibulum, sapien enim egestas dui, in mollis nisl lacus vestibulum mauris. Nulla pulvinar tempor neque ut elementum. Duis pellentesque tortor et turpis sagittis bibendum. Pellentesque faucibus ante a metus elementum sed ultricies libero tempus. Donec suscipit, augue sit amet suscipit pulvinar, dui tellus congue sapien, blandit tempor lacus mi id nulla. Nam eu magna lectus, id placerat sem.")
		exercise711.section = section71
		exercise711.save(:validate => false)

		exercise712 = Exercise.new(:proj_type => 'c', :index => 2, :content => "Ut at nisi libero. Nunc nisi nunc, venenatis a vulputate at, sagittis sit amet sapien. Morbi venenatis ornare imperdiet. Vivamus vitae dui nisl. Nullam ut nulla non enim euismod ullamcorper eget at nunc. In hac habitasse platea dictumst. Maecenas sed eros ut risus tristique rhoncus. Phasellus congue tellus non augue fermentum vitae scelerisque magna vulputate. Nullam vitae mauris at ante congue adipiscing. Aenean sed lobortis nisl.")
		exercise712.section = section71
		exercise712.save(:validate => false)

		exercise713 = Exercise.new(:proj_type => 'c', :index => 3, :content => "Donec vel risus et arcu faucibus scelerisque. Sed lorem nunc, commodo at posuere sed, imperdiet sit amet odio. Vivamus sed diam augue. Etiam vitae nisi nisi. Phasellus et leo justo, id iaculis ipsum. Curabitur justo dui, malesuada cursus dapibus aliquet, sollicitudin vitae neque. Quisque eu ante vel urna bibendum gravida.")
		exercise713.section = section71
		exercise713.save(:validate => false)

		exercise714 = Exercise.new(:proj_type => 'c', :index => 4, :content => "Fusce quam ipsum, hendrerit ac vehicula eu, semper at purus. Donec faucibus dictum justo, ut imperdiet augue fermentum ultricies. In metus sapien, semper vel euismod eget, pellentesque quis urna. Fusce ultricies metus accumsan nibh semper sagittis. Duis aliquam, metus tristique feugiat dapibus, felis nibh dictum nunc, et vehicula eros nunc a libero. Quisque non nisi sem, in sodales dolor. Vivamus hendrerit mattis condimentum. Fusce risus ipsum, vulputate at imperdiet nec, congue sit amet urna.")
		exercise714.section = section71
		exercise714.save(:validate => false)


		#template_file
		tmpltFile111 = TemplateFile.new(:file_name => "testTemplate111.c", :content => '#include <stdio.h>

int main(int argc, char *argv[]) {
	printf("Hello, world!\n");
	return 0;
}')
		tmpltFile111.exercise = exercise111
		tmpltFile111.save(:validate => false)

		tmpltFile112 = TemplateFile.new(:file_name => "testTemplate112.c", :content => '#include <stdio.h>

int main(int argc, char *argv[]) {
	printf("Hello, world!\n");
	return 0;
}')
		tmpltFile112.exercise = exercise112
		tmpltFile112.save(:validate => false)

		tmpltFile113 = TemplateFile.new(:file_name => "testTemplate113.c", :content => '#include <stdio.h>

int main(int argc, char *argv[]) {
	printf("Hello, world!\n");
	return 0;
}')
		tmpltFile113.exercise = exercise113
		tmpltFile113.save(:validate => false)

		tmpltFile114 = TemplateFile.new(:file_name => "testTemplate114.c", :content => '#include <stdio.h>

int main(int argc, char *argv[]) {
	printf("Hello, world!\n");
	return 0;
}')
		tmpltFile114.exercise = exercise114
		tmpltFile114.save(:validate => false)

		tmpltFile115 = TemplateFile.new(:file_name => "testTemplate115.c", :content => '#include <stdio.h>

int main(int argc, char *argv[]) {
	printf("Hello, world!\n");
	return 0;
}')
		tmpltFile115.exercise = exercise115
		tmpltFile115.save(:validate => false)

		tmpltFile121 = TemplateFile.new(:file_name => "testTemplate121.c", :content => '#include <stdio.h>

int main(int argc, char *argv[]) {
	printf("Hello, world!\n");
	return 0;
}')
		tmpltFile121.exercise = exercise121
		tmpltFile121.save(:validate => false)

		tmpltFile122 = TemplateFile.new(:file_name => "testTemplate122.c", :content => '#include <stdio.h>

int main(int argc, char *argv[]) {
	printf("Hello, world!\n");
	return 0;
}')
		tmpltFile122.exercise = exercise122
		tmpltFile122.save(:validate => false)

		tmpltFile123 = TemplateFile.new(:file_name => "testTemplate123.c", :content => '#include <stdio.h>

int main(int argc, char *argv[]) {
	printf("Hello, world!\n");
	return 0;
}')
		tmpltFile123.exercise = exercise123
		tmpltFile123.save(:validate => false)

		tmpltFile131 = TemplateFile.new(:file_name => "testTemplate131.c", :content => '#include <stdio.h>

int main(int argc, char *argv[]) {
	printf("Hello, world!\n");
	return 0;
}')
		tmpltFile131.exercise = exercise131
		tmpltFile131.save(:validate => false)

		tmpltFile141 = TemplateFile.new(:file_name => "testTemplate141.c", :content => '#include <stdio.h>

int main(int argc, char *argv[]) {
	printf("Hello, world!\n");
	return 0;
}')
		tmpltFile141.exercise = exercise141
		tmpltFile141.save(:validate => false)

		tmpltFile151 = TemplateFile.new(:file_name => "testTemplate151.c", :content => '#include <stdio.h>

int main(int argc, char *argv[]) {
	printf("Hello, world!\n");
	return 0;
}')
		tmpltFile151.exercise = exercise151
		tmpltFile151.save(:validate => false)

		tmpltFile152 = TemplateFile.new(:file_name => "testTemplate152.c", :content => '#include <stdio.h>

int main(int argc, char *argv[]) {
	printf("Hello, world!\n");
	return 0;
}')
		tmpltFile152.exercise = exercise152
		tmpltFile152.save(:validate => false)

		tmpltFile153 = TemplateFile.new(:file_name => "testTemplate153.c", :content => '#include <stdio.h>

int main(int argc, char *argv[]) {
	printf("Hello, world!\n");
	return 0;
}')
		tmpltFile153.exercise = exercise153
		tmpltFile153.save(:validate => false)

		tmpltFile211 = TemplateFile.new(:file_name => "testTemplate211.c", :content => '#include <stdio.h>

int main(int argc, char *argv[]) {
	printf("Hello, world!\n");
	return 0;
}')
		tmpltFile211.exercise = exercise211
		tmpltFile211.save(:validate => false)

		tmpltFile212 = TemplateFile.new(:file_name => "testTemplate212.c", :content => '#include <stdio.h>

int main(int argc, char *argv[]) {
	printf("Hello, world!\n");
	return 0;
}')
		tmpltFile212.exercise = exercise212
		tmpltFile212.save(:validate => false)

		tmpltFile221 = TemplateFile.new(:file_name => "testTemplate221.c", :content => '#include <stdio.h>

int main(int argc, char *argv[]) {
	printf("Hello, world!\n");
	return 0;
}')
		tmpltFile221.exercise = exercise221
		tmpltFile221.save(:validate => false)

		tmpltFile231 = TemplateFile.new(:file_name => "testTemplate231.c", :content => '#include <stdio.h>

int main(int argc, char *argv[]) {
	printf("Hello, world!\n");
	return 0;
}')
		tmpltFile231.exercise = exercise231
		tmpltFile231.save(:validate => false)

		tmpltFile232 = TemplateFile.new(:file_name => "testTemplate232.c", :content => '#include <stdio.h>

int main(int argc, char *argv[]) {
	printf("Hello, world!\n");
	return 0;
}')
		tmpltFile232.exercise = exercise232
		tmpltFile232.save(:validate => false)

		tmpltFile311 = TemplateFile.new(:file_name => "testTemplate311.c", :content => '#include <stdio.h>

int main(int argc, char *argv[]) {
	printf("Hello, world!\n");
	return 0;
}')
		tmpltFile311.exercise = exercise311
		tmpltFile311.save(:validate => false)

		tmpltFile312 = TemplateFile.new(:file_name => "testTemplate312.c", :content => '#include <stdio.h>

int main(int argc, char *argv[]) {
	printf("Hello, world!\n");
	return 0;
}')
		tmpltFile312.exercise = exercise312
		tmpltFile312.save(:validate => false)

		tmpltFile313 = TemplateFile.new(:file_name => "testTemplate313.c", :content => '#include <stdio.h>

int main(int argc, char *argv[]) {
	printf("Hello, world!\n");
	return 0;
}')
		tmpltFile313.exercise = exercise313
		tmpltFile313.save(:validate => false)

		tmpltFile314 = TemplateFile.new(:file_name => "testTemplate314.c", :content => '#include <stdio.h>

int main(int argc, char *argv[]) {
	printf("Hello, world!\n");
	return 0;
}')
		tmpltFile314.exercise = exercise314
		tmpltFile314.save(:validate => false)

		tmpltFile321 = TemplateFile.new(:file_name => "testTemplate321.c", :content => '#include <stdio.h>

int main(int argc, char *argv[]) {
	printf("Hello, world!\n");
	return 0;
}')
		tmpltFile321.exercise = exercise321
		tmpltFile321.save(:validate => false)

		tmpltFile322 = TemplateFile.new(:file_name => "testTemplate322.c", :content => '#include <stdio.h>

int main(int argc, char *argv[]) {
	printf("Hello, world!\n");
	return 0;
}')
		tmpltFile322.exercise = exercise322
		tmpltFile322.save(:validate => false)

		tmpltFile411 = TemplateFile.new(:file_name => "testTemplate411.c", :content => '#include <stdio.h>

int main(int argc, char *argv[]) {
	printf("Hello, world!\n");
	return 0;
}')
		tmpltFile411.exercise = exercise411
		tmpltFile411.save(:validate => false)

		tmpltFile412 = TemplateFile.new(:file_name => "testTemplate412.c", :content => '#include <stdio.h>

int main(int argc, char *argv[]) {
	printf("Hello, world!\n");
	return 0;
}')
		tmpltFile412.exercise = exercise412
		tmpltFile412.save(:validate => false)

		tmpltFile413 = TemplateFile.new(:file_name => "testTemplate413.c", :content => '#include <stdio.h>

int main(int argc, char *argv[]) {
	printf("Hello, world!\n");
	return 0;
}')
		tmpltFile413.exercise = exercise413
		tmpltFile413.save(:validate => false)

		tmpltFile511 = TemplateFile.new(:file_name => "testTemplate511.c", :content => '#include <stdio.h>

int main(int argc, char *argv[]) {
	printf("Hello, world!\n");
	return 0;
}')
		tmpltFile511.exercise = exercise511
		tmpltFile511.save(:validate => false)

		tmpltFile611 = TemplateFile.new(:file_name => "testTemplate611.c", :content => '#include <stdio.h>

int main(int argc, char *argv[]) {
	printf("Hello, world!\n");
	return 0;
}')
		tmpltFile611.exercise = exercise611
		tmpltFile611.save(:validate => false)

		tmpltFile612 = TemplateFile.new(:file_name => "testTemplate612.c", :content => '#include <stdio.h>

int main(int argc, char *argv[]) {
	printf("Hello, world!\n");
	return 0;
}')
		tmpltFile612.exercise = exercise612
		tmpltFile612.save(:validate => false)

		tmpltFile613 = TemplateFile.new(:file_name => "testTemplate613.c", :content => '#include <stdio.h>

int main(int argc, char *argv[]) {
	printf("Hello, world!\n");
	return 0;
}')
		tmpltFile613.exercise = exercise613
		tmpltFile613.save(:validate => false)

		tmpltFile614 = TemplateFile.new(:file_name => "testTemplate614.c", :content => '#include <stdio.h>

int main(int argc, char *argv[]) {
	printf("Hello, world!\n");
	return 0;
}')
		tmpltFile614.exercise = exercise614
		tmpltFile614.save(:validate => false)

		tmpltFile615 = TemplateFile.new(:file_name => "testTemplate615.c", :content => '#include <stdio.h>

int main(int argc, char *argv[]) {
	printf("Hello, world!\n");
	return 0;
}')
		tmpltFile615.exercise = exercise615
		tmpltFile615.save(:validate => false)

		tmpltFile616 = TemplateFile.new(:file_name => "testTemplate616.c", :content => '#include <stdio.h>

int main(int argc, char *argv[]) {
	printf("Hello, world!\n");
	return 0;
}')
		tmpltFile616.exercise = exercise616
		tmpltFile616.save(:validate => false)

		tmpltFile621 = TemplateFile.new(:file_name => "testTemplate621.c", :content => '#include <stdio.h>

int main(int argc, char *argv[]) {
	printf("Hello, world!\n");
	return 0;
}')
		tmpltFile621.exercise = exercise621
		tmpltFile621.save(:validate => false)

		tmpltFile631 = TemplateFile.new(:file_name => "testTemplate631.c", :content => '#include <stdio.h>

int main(int argc, char *argv[]) {
	printf("Hello, world!\n");
	return 0;
}')
		tmpltFile631.exercise = exercise631
		tmpltFile631.save(:validate => false)

		tmpltFile632 = TemplateFile.new(:file_name => "testTemplate632.c", :content => '#include <stdio.h>

int main(int argc, char *argv[]) {
	printf("Hello, world!\n");
	return 0;
}')
		tmpltFile632.exercise = exercise632
		tmpltFile632.save(:validate => false)

		tmpltFile711 = TemplateFile.new(:file_name => "testTemplate711.c", :content => '#include <stdio.h>

int main(int argc, char *argv[]) {
	printf("Hello, world!\n");
	return 0;
}')
		tmpltFile711.exercise = exercise711
		tmpltFile711.save(:validate => false)

		tmpltFile712 = TemplateFile.new(:file_name => "testTemplate712.c", :content => '#include <stdio.h>

int main(int argc, char *argv[]) {
	printf("Hello, world!\n");
	return 0;
}')
		tmpltFile712.exercise = exercise712
		tmpltFile712.save(:validate => false)

		tmpltFile713 = TemplateFile.new(:file_name => "testTemplate713.c", :content => '#include <stdio.h>

int main(int argc, char *argv[]) {
	printf("Hello, world!\n");
	return 0;
}')
		tmpltFile713.exercise = exercise713
		tmpltFile713.save(:validate => false)

		tmpltFile714 = TemplateFile.new(:file_name => "testTemplate714.c", :content => '#include <stdio.h>

int main(int argc, char *argv[]) {
	printf("Hello, world!\n");
	return 0;
}')
		tmpltFile714.exercise = exercise714
		tmpltFile714.save(:validate => false)


  end
end
