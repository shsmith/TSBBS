TYPE
    byte = 0..255;

    system_status_type = PACKED RECORD
        enabled:                BOOLEAN;
        buffered_write_enabled: BOOLEAN;
        buffered_read_enabled:  BOOLEAN;
        sounds_enabled:         BOOLEAN;
        autodismount_enabled:   BOOLEAN;

        reserved_3:             BOOLEAN;
        reserved_4:             BOOLEAN;
        reserved_5:             BOOLEAN;

        em_assigned:            BOOLEAN;
        emulated_emm:           BOOLEAN;

        single_sector_bonus:    byte;
        sticky_max:             byte;
        write_sector_bonus:     byte;
        bonus_threshold:        byte;

        flush_interval:         CARDINAL;
        flush_count:            INTEGER;
        reserve_pool_size:      INTEGER;
        reserve_pool_remaining: INTEGER;
        rqd_free_memory:        CARDINAL;
     
        total_sectors,
        dirty_sectors:          INTEGER;

        track_buffer_size:      byte;
        filler2:                byte;
        END;

    drive_status_type = PACKED RECORD
        dos_drive:              byte;
        bios_drive:             byte;
        max_sector:             byte;
        max_head:               byte;
        read_buffer_size:       byte;
        write_buffer_size:      byte;
        last_status:            byte;   
       
        enabled:                BOOLEAN;
        buffered_write_enabled: BOOLEAN;
        buffered_read_enabled:  BOOLEAN;
        in_use:                 BOOLEAN;
        cylinder_flush:         BOOLEAN;
        filler0:                BOOLEAN;

        sectors_per_track:      byte;

        sector_size:            INTEGER;
        sectors_assigned:       CARDINAL;
        dirty_sectors:          CARDINAL;
        reserved_sectors:       CARDINAL;
        read_error_count:       CARDINAL;
        write_error_count:      CARDINAL;

        rio_count:              LONGINT;
        miss_count:             LONGINT;
        wio_count:              LONGINT;
        dio_count:              LONGINT;
        END;

        all_drive_status_type = ARRAY[0..15] OF drive_status_type;
        
{==============================================================================}
{                           Drive translation table                            }
{                                                                              }
{  This table is used to generate an index into each of the drive status       }
{  tables.  Drive A is element zero of the drive_index array, drive B is       }
{  element 1, etc.  If the index extracted is not 255, then the drive is valid }
{  and it may be used to index into the status tables.                         }
{                                                                              }
{==============================================================================}

    drive_index_type =          PACKED ARRAY[0..31] OF 0..255;

    cache_status_type =         RECORD
        CASE INTEGER OF
            0: (
                system:                 system_status_type
                );

            1: (
                drive:                  all_drive_status_type;
                );

            2: (
                access_frequency:       ARRAY[1..30] OF CARDINAL
                );

            3: (
                drive_index:            drive_index_type;
                );
            END;

