	  �  .   k820309    k          13.1        ��gR                                                                                                           
       mod_reef.f90 MOD_REEF                                                    
                                                          
                                                          
                                                          
                                                         KIND                                                                                                                                                                                                                                                                                                                   #         @                                  	                    #IUNIT 
                                             
            #         @                                                      #IUNIT              
                                                                                                                                                                                                                                     �Q             86400#         @                                                     #CDATE%MOD    #CDATE%INT    #JD    #YYYY    #MM    #DD                                                     MOD                                                  INT           
                                                                                                                                                                                                                       @@                                                 	                &                                                    @@                                                 	                &                                                    @                                                  	                &                                                    @                                                                  &                                                    @                                                                  &                                                      @                                           #         @                                                      #LOAD_REEF_DATA%INT    #LOAD_REEF_DATA%TRIM    #POLYFILENAME                                                    INT                                                 TRIM           
@ @                                                  1 #         @                                                        #LONSTART !   #LATSTART "   #ID #             
@ @                              !     	                
@ @                              "     	                
                                 #           #         @                                   $                   #CHECK_REEF_RECRUITMENT%INT %   #LONEND &   #LATEND '   #DEPTHEND (   #RUN_TIME )   #JULIAN *   #R +   #INPOLY ,                                              %     INT           
@ @                              &     	                
@ @                              '     	                
@ @                              (     	                
@ @                              )                     
  @                              *                     
@ @                              +                     D                                ,            #         @                                   -                        �         fn#fn    �   @   J   MOD_KINDS    �   @   J   CONSTANTS    >  @   J   MOD_CALENDAR    ~  @   J   MOD_IOUNITS    �  =       KIND+MOD_KINDS $   �  p       REAL_KIND+MOD_KINDS #   k  p       INT_KIND+MOD_KINDS #   �  p       LOG_KIND+MOD_KINDS %   K  S       GET_UNIT+MOD_IOUNITS +   �  @   a   GET_UNIT%IUNIT+MOD_IOUNITS )   �  S       RELEASE_UNIT+MOD_IOUNITS /   1  @   a   RELEASE_UNIT%IUNIT+MOD_IOUNITS $   q  p       INT8_KIND+MOD_KINDS &   �  u       SECS_IN_DAY+CONSTANTS #   V  �       CDATE+MOD_CALENDAR '   �  <      CDATE%MOD+MOD_CALENDAR '     <      CDATE%INT+MOD_CALENDAR &   V  @   a   CDATE%JD+MOD_CALENDAR (   �  @   a   CDATE%YYYY+MOD_CALENDAR &   �  @   a   CDATE%MM+MOD_CALENDAR &     @   a   CDATE%DD+MOD_CALENDAR    V  �       POLYLONS    �  �       POLYLATS    n  �       POLYID    �  �       POLYBGN    �	  �       POLYEND    
  @       NPOLY    R
  �       LOAD_REEF_DATA #   �
  <      LOAD_REEF_DATA%INT $     =      LOAD_REEF_DATA%TRIM ,   V  L   a   LOAD_REEF_DATA%POLYFILENAME &   �  l       CHECK_RELEASE_POLYGON /     @   a   CHECK_RELEASE_POLYGON%LONSTART /   N  @   a   CHECK_RELEASE_POLYGON%LATSTART )   �  @   a   CHECK_RELEASE_POLYGON%ID '   �  �       CHECK_REEF_RECRUITMENT +   �  <      CHECK_REEF_RECRUITMENT%INT .   �  @   a   CHECK_REEF_RECRUITMENT%LONEND .     @   a   CHECK_REEF_RECRUITMENT%LATEND 0   E  @   a   CHECK_REEF_RECRUITMENT%DEPTHEND 0   �  @   a   CHECK_REEF_RECRUITMENT%RUN_TIME .   �  @   a   CHECK_REEF_RECRUITMENT%JULIAN )     @   a   CHECK_REEF_RECRUITMENT%R .   E  @   a   CHECK_REEF_RECRUITMENT%INPOLY    �  H       DEALLOC_REEF 