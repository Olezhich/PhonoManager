TARGET_FILE_EXT = cue flac ape wav mp3 m4a

# CACHE = .cache

# DIRS_W_TARGET_FILES := $(sort $(dir $(shell find . -type f \( -false $(foreach ext,$(TARGET_FILE_EXT),-o -name "*.$(ext)") \) 2>/dev/null)))

# UNIQUE_DIRS_W_TARGET_FILES := $(sort $(DIRS_W_TARGET_FILES))

# CACHE_TARGETS := $(addsuffix $(CACHE), $(UNIQUE_DIRS_W_TARGET_FILES))

cache := .cache
cache_target := music/.cache

flac := music/audio.flac
cue := music/audio.cue

playlist: $(cache_target)
	touch $@

.SECONDEXPANSION:
%$(cache): $$(wildcard $$(addprefix $$(dir $$(cache_target))*., $$(TARGET_FILE_EXT)))
	touch $@

debug:
	$(info cache = $(cache))
	$(info cache_target = $(cache_target))
	$(info notdir часть: $(notdir $(dir $(cache_target))))
	$(info результат addsuffix:)
	$(info $(wildcard $(addprefix $(dir $(cache_target))*., $(TARGET_FILE_EXT))))

# .SECONDEXPANSION:
# %$(cache): $$(flac) $$(cue)
# 	touch $@

