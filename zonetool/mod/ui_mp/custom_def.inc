#ifdef PC
	#define OPEN_ARMORY_MENU \
	if(DvarString ("open_armory_menu") == "weapon")close self;open weapons;\
	if(DvarString ("open_armory_menu") == "support")close self;open support;\
	if(DvarString ("open_armory_menu") == "equipment")close self;open equipment;
#endif