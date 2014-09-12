;; Contract: Users
;; This contract is used to manage user accounts. It utilizes the linked list
;; and string libraries to check that user names are alphanumeric (and between
;; 3 and 15 characters long), and to link user data into a collection that can
;; be iterated over.
;;
;; Author:
;; Andreas Olofsson (androlo1908@gmail.com)
;;
;; License:
;; https://github.com/androlo/LLL-commons/blob/master/LICENSE.md
;; 
{
	;; Library: LinkedList
	;;
	;; This is an include for contracts using a standard doubly linked list.
	;; The list works with pointers to elements, and has no idea about what
	;; those pointers actually are. 
	;;
	;; The list 'object' itself requires 3 storage addresses, one for the
	;; list size, one for a pointer to the tail element, and one for a pointer
	;; to the head element.
	;;
	;; A list element needs two storage addresses pointing to its 'previous' and 
	;; 'next' element. Element data is stored in consecutive storage addresses 
	;; starting at 'elemAddress'.
	;;
	;; (see LinkedListElement.png)
	;;
	;; The previous/next element pointers are added and removed automatically, but 
	;; elements must be created manually (to avoid weird, additional for-loops etc.).
	;; This would be an example of how to create an element with storage address 
	;; (CALLER) that stores one single element (a user name).
	;;
	;; (begin code)
	;; [[(CALLER)]] "userName"
	;; ; Add a cross reference maybe?
	;; [["userName"]] (CALLER)
	;; (addToList (CALLER))
	;; (end)
	;;
	;; Storage-addresses for elements are handed to the list by the user. This is 
	;; practical when you use the typical [[(CALLER]] or [["name"]], like in user 
	;; and bank contracts. If you want storage addresses to be allocated automatically, 
	;; use LinkedListAM (Address Managed).
	;;
	;; For example usage, see the example/users.lsp contract. 
	;; 
	;; Version:
	;; 0.0.1
	;;
	;; Authors:
	;; Andreas Olofsson (androlo1980@gmail.com)
	;;
	;; License:
	;; https://github.com/androlo/LLL-commons/blob/master/LICENSE.md
	;;
	;; StorageReq:
	;; SIZE_ADDR - defaults to 0x11
	;; TAIL_ADDR - defaults to 0x12
	;; HEAD_ADDR - defaults to 0x13
	{
		;; Constants: Addresses
		;;
		;; SIZE_ADDR - the storage address used for list size.
		;; TAIL_ADDR - the storage address used for tail.
		;; HEAD_ADDR - the storage address used for head.
		(def "SIZE_ADDR" 0x11)
	    (def "TAIL_ADDR" 0x12)
	    (def "HEAD_ADDR" 0x13)
		
		;; Function: _setHead (newHeadAddr)
		;;
		;; Set the head element. Should not be called directly.
		;;
		;; Parameters:
		;; newHeadAddr - Address to the new head.
		;;
		;; Returns:
		;; void
	    (def "_setHead" (newHeadAddr) [[HEAD_ADDR]] newHeadAddr)
	    
	    ;; Function: _setTail (newTailAddr)
		;;
		;; Set the tail element. Should not be called directly.
		;;
		;; Parameters:
		;; newTailAddr - Address to the new tail.
		;;
		;; Returns:
		;; void
	    (def "_setTail" (newTailAddr) [[TAIL_ADDR]] newTailAddr)
	    
	    ;; Function: _setPrev (elemAddr newPrevAddr)
		;;
		;; Set the previous element of an existing element. Should not be called directly.
		;;
		;; Parameters:
		;; elemAddr - Address to the current element.
		;; newPrevAddr - Address to the element that will be the new 'prev'
		;;
		;; Returns:
		;; void
	    (def "_setPrev" (elemAddr newPrevAddr) 
	    	{
	    		[[(- elemAddr 1)]] newPrevAddr
	    	}
	    )
	    
	    ;; Function: _setNext (elemAddr newNextAddr)
		;;
		;; Set the next element of an existing element. Should not be called directly.
		;;
		;; Parameters:
		;; elemAddr - Address to the current element.
		;; newNextAddr - Address to the element that will be the new 'next'
		;;
		;; Returns:
		;; void
	    (def "_setNext" (elemAddr newNextAddr) 
	    	{
	    		[[(- elemAddr 2)]] newNextAddr
	    	}
	    )
		
		;; Function: size ()
		;;
		;; Get the size of the list
		;;
		;; Parameters:
		;; void
		;;
		;; Returns:
		;; Size of the list.
	    (def "size" @@SIZE_ADDR)
	    
	    ;; Function: tail ()
		;;
		;; Get the tail element.
		;;
		;; Parameters:
		;; void
		;;
		;; Returns:
		;; Address of the tail element (or null).
	    (def "tail" @@TAIL_ADDR)
	    
	    ;; Function: head ()
		;;
		;; Get the head element.
		;;
		;; Parameters:
		;; void
		;;
		;; Returns:
		;; Address of the head element (or null).
	    (def "head" @@HEAD_ADDR)
	    
	    ;; Function: prev (elemAddr)
		;;
		;; Get the previous element.
		;;
		;; Parameters:
		;; elemAddr - Address to the current element.
		;;
		;; Returns:
		;; Address to the previous element (or null).
	    (def "prev" (elemAddr) @@(- elemAddr 1) )
	    
	    ;; Function: next (elemAddr)
		;;
		;; Get the next element element.
		;;
		;; Parameters:
		;; elemAddr - Address to the current element.
		;;
		;; Returns:
		;; Address to the next element (or null).
	    (def "next" (elemAddr) @@(- elemAddr 2) )
	    
	    ;; Function: addToList (elemAddr)
		;;
		;; Add a new element at the end of the list.
		;;
		;; Parameters:
		;; elemAddr - Address to the new element.
		;;
		;; Returns:
		;; void
	    (def "addToList" (elemAddr) 
	    	{
	    		[mTemp0] head
	    		[mTemp1] @@SIZE_ADDR
	    		(def "mHead" mTemp0) ; Store address to head at "mHead"
	    		(def "curSize" @mTemp1)
	    		(if curSize ; If there are elements in the list. 
					{
						;Set the 'next' of the current head to be this one.
						(_setNext @mHead elemAddr)
						;Now set the current head as this ones 'previous'.
						(_setPrev elemAddr @mHead)	
					} 
					{
						;If no elements, add this as tail
						(_setTail elemAddr)
					}
				)
				(_setHead elemAddr)
				;Increase the list size by one.
				[[SIZE_ADDR]] (+ curSize 1)
	    	}
	    )
	    
	    ;; Function: removeFromList (elemAddr)
		;;
		;; Remove an element from the list.
		;;
		;; Parameters:
		;; elemAddr - Address to the element.
		;;
		;; Returns:
		;; void
	    (def "removeFromList" (elemAddr) 
	    	{
	    		
	    		[mTemp0] (prev elemAddr) ; Here we store the this ones 'previous'.
				[mTemp1] (next elemAddr) ; And next
				
				(def "mThisPrevious" mTemp0 )
				(def "mThisNext" mTemp1 )
			
				; If we are not the head.
				(if @mThisNext
					{
						(if @mThisPrevious
							{
								;Change next elements 'previous' to this ones 'previous'.
								(_setPrev @mThisNext @mThisPrevious)
								;Change previous elements 'next' to this ones 'next'.
								(_setNext @mThisPrevious @mThisNext)
							}
							{
								; We are tail. Set next elements previous to 0
								(_setPrev @mThisNext 0)
								; Set next element as current tail.
								(_setTail @mThisNext)
							}
						)
					}

					{
						(if @mThisPrevious
							{
								;This element is the head - unset 'next' for the previous element making it the head.
								(_setNext @mThisPrevious 0)
								;Set previous as head
								(_setHead @mThisPrevious)
							}
							{
								; This element is the tail - and the last element. Reset head and tail.
								(_setHead 0)
								(_setTail 0)
							}					
						)
					}
				)
				
				
				;Now clean up any head or prev this element might have had.
				(_setNext elemAddr 0)
				(_setPrev elemAddr 0)
				;Decrease the size counter
				[[SIZE_ADDR]] (- size 1)
	    	}
	    )
	    
	}
	;; Library: String
	;;
	;; This library contains functions that operate on strings.
	;;
	;; Standard ASCII set, ISO 10646, ISO 8879, ISO 8859-1 Latin alphabet No. 1
	;; http://www.ascii.cl/htmlcodes.htm
	;; 
	;; Version: 
	;; 0.0.1
	;;
	;; Authors:
	;; Andreas Olofsson (androlo1980@gmail.com)
	;;
	;; License:
	;; https://github.com/androlo/LLL-commons/blob/master/LICENSE.md
	{
		;; Library: StdLib
		;;
		;; This library contains standard functions and operators.
		;; 
		;; Version: 
		;; 0.0.1
		;;
		;; Authors:
		;; Andreas Olofsson (androlo1980@gmail.com)
		;;
		;; License:
		;; https://github.com/androlo/LLL-commons/blob/master/LICENSE.md
		{
			
			;; Operator: ++ (var)
			;;
			;; Increases the value held at memory address 'var' by one.
			;; : [var] (+ @var 1)
			;;
			;; Parameters:
			;; var - the address
			;;
			;; Returns:
			;; void
			(def "++" (var) [var] (+ @var 1))
			
			;; Operator: -- (var)
			;;
			;; Decreases the value held at memory address 'var' by one. 
			;; : [var] (- @var 1)
			;;
			;; Parameters:
			;; var - the address
			;;
			;; Returns:
			;; void
			(def "--" (var) [var] (- @var 1))
			
			;; Function: sfor (param start end expr)
			;;
			;; Does a simple for-loop. It needs to be provided a memory address
			;; or a variable as the first param. The second and third param are
			;; the start and end values, and the last param is the expression that
			;; should be carried out each iteration.
			;;
			;; The example would print calldataload up to 0x80 to storage.
			;; (start code)
			;; (sfor index 0 5 
			;;    {
			;;		 [[@index]] $(* @index 32)
			;; 	  }
			;; )
			;; (end)
			;;
			;; Parameters:
			;; param - The memory address (or variable name).
			;; start - The starting index (usually 0).
			;; end - The end index.
			;; expr - The expression to be carried out each iteration.
			;;
			;; Returns:
			;; void
			(def "sfor" (param start end expr)
				(for [param] start (< @param end) (++ param) expr )
			)
			
			;; Function: kill (callerAddress)
			;;
			;; Kill is used to suicide the contract and return its ether to the caller.
			;;
			;; Parameters:
			;; callerAddress - The address of the caller.
			;;
			;; Returns:
			;; void
			(def "kill" (callerAddress) (suicide (CALLER)) )
			
			;; Function: kill (callerAddress)
			;;
			;; Kill is used to suicide the contract and return its ether to the caller.
			;; It can only be done by the creator of the contract.
			;;
			;; Parameters:
			;; callerAddress - The address of the caller
			;; creatorAddress - The address of the contract creator.
			;;
			;; Returns:
			;; void
			(def "kill" (callerAddress creatorAddress)
				{
					(when (= callerAddress creatorAddress) (suicide (CALLER)) )
				}
			)
			
		}
		
		
		;; Function: isCharAlphaNum (name)
		;;
		;; Checks if a single char (byte) is alphanumeric. See 'isStringAlphaNum'
		;;
		;; Parameters:
		;; char - the character
		;;
		;; Returns:
		;; 1 if it is alphanumeric, otherwise 0
		(def "isCharAlphaNum" (char) 
			(|| (&& (> char 47)  (< char 58) ) 
				(&& (> char 64)  (< char 91) ) 
				(&& (> char 96)  (< char 123)) 
			)
		)
		
		;; Function: isCharAlphaNumExt (name)
		;;
		;; Checks if a single char (byte) is alphanumeric or extended. See 'isStringAlphaNumExt'
		;;
		;; Parameters:
		;; char - the character
		;;
		;; Returns:
		;; 1 if it is alphanumeric, otherwise 0	
		(def "isCharAlphaNumExt" (char) 
			(|| (&& (> char 47)  (< char 58) ) 
				(&& (> char 64)  (< char 91) ) 
				(&& (> char 96)  (< char 123)) 
				(&& (> char 191) (< char 215))
				(&& (> char 215) (< char 247))
				(&& (> char 247) (< char 256)) 
			)
		)
		
		;; Function: isCharBlank (name)
		;;
		;; Checks if a single char (byte) is blank (equal to zero)
		;;
		;; Parameters:
		;; char - the character
		;;
		;; Returns:
		;; 1 if it is blank, otherwise 0
		(def "isCharBlank" (char) (= char 0) )
		
		;; Function: isStringAlphaNum (name)
		;;
		;; Checks if the name is a proper alphanumeric string consisting of 'minLength' to
		;; 'maxLength characters. The normal regex would be [0-9a-zA-Z]. Stops execution
		;; by returning 1 or 0.
		;;
		;; Parameters:
		;; name - the string that is going to be checked.
		;; minLength - the minimum length of the string.
		;; maxLength - the maximum length of the string (<= 32).
		;;
		;; Returns:
		;; void
		(def "isStringAlphaNum" (name minLength maxLength)
			{
				; Do this to re-use memory if temps have been already used.
				[mTemp0] 0
				[mTemp1] 0
				(def "mIndex" mTemp0)
				(def "mChar" mTemp1)
				
				(while (< @mIndex minLength)
					{
						[mChar] (byte @mIndex name)
						(unless (isCharAlphaNum @mChar) (return 0) )
						(++ mIndex)
					}
				)
				(while (< @mIndex maxLength)
					{
						(unless (|| (isCharAlphaNum @mChar) (isCharBlank @mChar) ) (return 0) )
						; After a blank, the rest must be blanks too.
						(unless @mChar
							{
								(++ mIndex); skip ahead by one.
								
								(while (< @mIndex maxLength)
									{
										[mChar] (byte @mIndex name)
										; If not blank - cancel.
										(when @mChar (return 0) )
										(++ mIndex)
									}
								)
								(-- mIndex) ; back one step since it will be incremented before escaping the loop.
							}
						)
						(++ mIndex)
					}
				)
				(while (< @mIndex 32)
					{
						[mChar] (byte @mIndex name)
						; If not blank - cancel.
						(when @mChar { (return 0) } )
						(++ mIndex)
					}
				)
			}
		)
		
		;; Function: isStringAlphaNumExt (name)
		;;
		;; Checks if the name is a proper alphanumeric string consisting of 'minLength' to
		;; 'maxLength characters, with additional characters allowed. The added range is
		;; 192-255 (with the exception of 215 and 247).
		;;
		;; Parameters:
		;; name - the string that is going to be checked.
		;; minLength - the minimum length of the string.
		;; maxLength - the maximum length of the string (<= 32).
		;;
		;; Returns:
		;; 1 if success, and 0 if fail.
		(def "isStringAlphaNumExt" (name minLength maxLength)
			{
				[mTemp0] 0
				[mTemp1] 0
				
				(def "mIndex" mTemp0)
				(def "mChar" mTemp1)
				
				(while (< @mIndex minLength)
					{
						[mChar] (byte @mIndex name)
						(unless (isCharAlphaNumExt @mChar) (return 0) )
						(++ mIndex)
					}
				)
				
				(while (< @mIndex maxLength)
					{
						(unless (|| (isCharAlphaNumExt @mChar) (isCharBlank @mChar) ) (return 0) )
						; After a blank, the rest must be blanks too.
						(unless @mChar
							{
								(++ mIndex); skip ahead by one.
								
								(while (< @mIndex maxLength)
									{
										[mChar] (byte @mIndex name)
										; If not blank - cancel.
										(when @mChar (return 0) )
										(++ mIndex)
									}
								)
								(-- mIndex) ; back one step since it will be incremented before escaping the loop.
							}
						)
						(++ mIndex)
					}
				)
				(while (< @mIndex 32)
					{
						[mChar] (byte @mIndex name)
						; If not blank - cancel.
						(when @mChar { (return 0) } )
						(++ mIndex)
					}
				)
			}
		)
		
		
	}
	; stdlib loaded automatically through string.linc
	
	; DEFINES
	
	(def "CREATOR_ADDR" 0x1)
		
	;; Function: register (userName)
	;;
	;; Register a user.
	;;
	;; Parameters:
	;; userName - The name that the caller wants to use.
	;;
	;; Returns:
	;; 1 if successful, otherwise 0.
	(def "register" (userName) 
		{
			; When the username is taken, break.
			(when @@userName (return 0))
			; When the caller already has a name, break.
			(when @@(CALLER) (return 0))
			
			(isStringAlphaNum userName 3 15) ; Check if it name is alphanumeric.
			
			[[(CALLER)]] txUserName
			[[txUserName]] (CALLER)
			; Add this entry to the list.
			(addToList (CALLER))
		}
	)
	
	;; Function: deregister ()
	;;
	;; Deregister a user.
	;;
	;; Parameters:
	;; void
	;;
	;; Returns:
	;; 1 if successful, otherwise 0.
	(def "deregister" 
		{
			[mUserName] @@(CALLER)
			; When the caller already has a name, break.
			(unless @mUserName (return 0))
			; Clean up name and address cross reference
			[[@mUserName]] 0
			[[(CALLER)]] 0
			; Remove from list
			(removeFromList (CALLER))
			(return 1)	
		}
	)
	
	; txdata
	(def "txKeyword" $0x0)
    (def "txUserName" $0x20)
    
    [[CREATOR_ADDR]] (CALLER)
	
	; BODY
	(returnlll 
    {
      	(when (= txKeyword "register") 
          	{
          		(register txUserName)
          	}
      	)
      	(when (= txKeyword "deregister") 
          	{
          		deregister
          	}
      	)
      	
      	(when (= txKeyword "kill")
          	{
              	(kill (CALLER) @@CREATOR_ADDR)
          	}
      	)
        (return 0)
    } )
}