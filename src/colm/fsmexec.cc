/*
 * Copyright 2007-2018 Adrian Thurston <thurston@colm.net>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to
 * deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 * sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#include <stdbool.h>

#include <assert.h>

#include "fsmcodegen.h"

static long actionLoc( RedAction *action )
{
	return action != 0 ? action->location + 1 : 0;
}

/* The tables for the table driven scanner below. The code generator writes
 * only the entry points and the start, first final and error states into the
 * program; the program runs the goto driven scanner. */
fsm_tables *LexReducer::makeFsmTables()
{
	/* The fsm runtime needs the states in id order. A state's id is its
	 * position in the state array; the list is in the code generator's
	 * order. */
	RedStateAp *firstState = redFsm->allStates;
	RedStateAp *endState = firstState + redFsm->stateList.length();

	int pos, curKeyOffset, curIndOffset;
	fsm_tables *fsmTables = new fsm_tables;
	fsmTables->num_states = redFsm->stateList.length();

	/*
	 * actions
	 */

	fsmTables->num_actions = 1;
	for ( GenActionTableMap::Iter act = redFsm->actionMap; act.lte(); act++ )
		fsmTables->num_actions += 1 + act->key.length();

	pos = 0;
	fsmTables->actions = new long[fsmTables->num_actions];
	fsmTables->actions[pos++] = 0;
	for ( GenActionTableMap::Iter act = redFsm->actionMap; act.lte(); act++ ) {
		fsmTables->actions[pos++] = act->key.length();
		for ( GenActionTable::Iter item = act->key; item.lte(); item++ )
			fsmTables->actions[pos++] = item->value->actionId;
	}

	/*
	 * keyOffset
	 */
	pos = 0, curKeyOffset = 0;
	fsmTables->key_offsets = new long[fsmTables->num_states];
	for ( RedStateAp *st = firstState; st < endState; st++ ) {
		/* Store the current offset. */
		fsmTables->key_offsets[pos++] = curKeyOffset;

		/* Move the key offset ahead. */
		curKeyOffset += st->outSingle.length() + st->outRange.length()*2;
	}

	/*
	 * transKeys
	 */
	fsmTables->num_trans_keys = 0;
	for ( RedStateAp *st = firstState; st < endState; st++ ) {
		fsmTables->num_trans_keys += st->outSingle.length();
		fsmTables->num_trans_keys += 2 * st->outRange.length();
	}

	pos = 0;
	fsmTables->trans_keys = new char[fsmTables->num_trans_keys];
	for ( RedStateAp *st = firstState; st < endState; st++ ) {
		for ( RedTransList::Iter stel = st->outSingle; stel.lte(); stel++ )
			fsmTables->trans_keys[pos++] = stel->lowKey.getVal();
		for ( RedTransList::Iter rtel = st->outRange; rtel.lte(); rtel++ ) {
			fsmTables->trans_keys[pos++] = rtel->lowKey.getVal();
			fsmTables->trans_keys[pos++] = rtel->highKey.getVal();
		}
	}

	/*
	 * singleLengths
	 */
	pos = 0;
	fsmTables->single_lengths = new long[fsmTables->num_states];
	for ( RedStateAp *st = firstState; st < endState; st++ )
		fsmTables->single_lengths[pos++] = st->outSingle.length();

	/*
	 * rangeLengths
	 */
	pos = 0;
	fsmTables->range_lengths = new long[fsmTables->num_states];
	for ( RedStateAp *st = firstState; st < endState; st++ )
		fsmTables->range_lengths[pos++] = st->outRange.length();

	/*
	 * indexOffsets
	 */
	pos = 0, curIndOffset = 0;
	fsmTables->index_offsets = new long[fsmTables->num_states];
	for ( RedStateAp *st = firstState; st < endState; st++ ) {
		fsmTables->index_offsets[pos++] = curIndOffset;

		curIndOffset += st->outSingle.length() + st->outRange.length();
		if ( st->defTrans != 0 )
			curIndOffset += 1;
	}

	/*
	 * transTargsWI
	 */
	fsmTables->numTransTargsWI = 0;
	for ( RedStateAp *st = firstState; st < endState; st++ ) {
		fsmTables->numTransTargsWI += st->outSingle.length();
		fsmTables->numTransTargsWI += st->outRange.length();
		if ( st->defTrans != 0 )
			fsmTables->numTransTargsWI += 1;
	}

	pos = 0;
	fsmTables->transTargsWI = new long[fsmTables->numTransTargsWI];
	for ( RedStateAp *st = firstState; st < endState; st++ ) {
		for ( RedTransList::Iter stel = st->outSingle; stel.lte(); stel++ )
			fsmTables->transTargsWI[pos++] = stel->value->p.targ->id;

		for ( RedTransList::Iter rtel = st->outRange; rtel.lte(); rtel++ )
			fsmTables->transTargsWI[pos++] = rtel->value->p.targ->id;

		if ( st->defTrans != 0 )
			fsmTables->transTargsWI[pos++] = st->defTrans->p.targ->id;
	}

	/*
	 * transActionsWI
	 */
	fsmTables->numTransActionsWI = 0;
	for ( RedStateAp *st = firstState; st < endState; st++ ) {
		fsmTables->numTransActionsWI += st->outSingle.length();
		fsmTables->numTransActionsWI += st->outRange.length();
		if ( st->defTrans != 0 )
			fsmTables->numTransActionsWI += 1;
	}

	pos = 0;
	fsmTables->transActionsWI = new long[fsmTables->numTransActionsWI];
	for ( RedStateAp *st = firstState; st < endState; st++ ) {
		for ( RedTransList::Iter stel = st->outSingle; stel.lte(); stel++ )
			fsmTables->transActionsWI[pos++] = actionLoc( stel->value->p.action );

		for ( RedTransList::Iter rtel = st->outRange; rtel.lte(); rtel++ )
			fsmTables->transActionsWI[pos++] = actionLoc( rtel->value->p.action );

		if ( st->defTrans != 0 )
			fsmTables->transActionsWI[pos++] = actionLoc( st->defTrans->p.action );
	}

	/*
	 * toStateActions
	 */
	pos = 0;
	fsmTables->to_state_actions = new long[fsmTables->num_states];
	for ( RedStateAp *st = firstState; st < endState; st++ )
		fsmTables->to_state_actions[pos++] = actionLoc( st->toStateAction );

	/*
	 * fromStateActions
	 */
	pos = 0;
	fsmTables->from_state_actions = new long[fsmTables->num_states];
	for ( RedStateAp *st = firstState; st < endState; st++ )
		fsmTables->from_state_actions[pos++] = actionLoc( st->fromStateAction );

	/*
	 * eofActions
	 */
	pos = 0;
	fsmTables->eof_actions = new long[fsmTables->num_states];
	for ( RedStateAp *st = firstState; st < endState; st++ ) {
		RedTransAp *eofTrans = LexReducer::eofTrans( st );
		fsmTables->eof_actions[pos++] = eofTrans != 0 ?
				actionLoc( eofTrans->p.action ) : 0;
	}

	/*
	 * eofTargs
	 */
	pos = 0;
	fsmTables->eof_targs = new long[fsmTables->num_states];
	for ( RedStateAp *st = firstState; st < endState; st++ ) {
		RedTransAp *eofTrans = LexReducer::eofTrans( st );
		fsmTables->eof_targs[pos++] = eofTrans != 0 ? eofTrans->p.targ->id : -1;
	}

	/* Start state. */
	fsmTables->start_state = redFsm->startState->id;

	/* First final state. */
	fsmTables->first_final = ( redFsm->firstFinState != 0 ) ?
		redFsm->firstFinState->id : redFsm->nextStateId;

	/* The error state. */
	fsmTables->error_state = ( redFsm->errState != 0 ) ?
		redFsm->errState->id : -1;

	/* The array pointing to actions. */
	pos = 0;
	fsmTables->num_action_switch = actionList.length();
	fsmTables->action_switch = new LexAction*[fsmTables->num_action_switch];
	for ( GenActionList::Iter act = actionList; act.lte(); act++ )
		fsmTables->action_switch[pos++] = lexAction( act );

	/*
	 * entryByRegion
	 */

	/* The entry map can hold an id more than once. The first one wins. */
	BstMap<int, long> entryMap;
	for ( EntryMap::Iter en = fsm->entryPoints; en.lte(); en++ )
		entryMap.insert( en->key, en->value->alg.stateNum );

	fsmTables->num_regions = pd->regionList.length()+1;
	fsmTables->entry_by_region = new long[fsmTables->num_regions];
	fsmTables->entry_by_region[0] = fsmTables->error_state;

	pos = 1;
	for ( RegionList::Iter reg = pd->regionList; reg.lte(); reg++ ) {
		assert( reg->id == pos - 1 );
		assert( reg->impl->regionNameInst != 0 );

		TokenRegion *use = reg;

		if ( use->zeroLel != 0 )
			use = use->ignoreOnly;

		/* Find the entry state from the entry id. */
		BstMapEl<int, long> *entryMapEl = entryMap.find( use->impl->regionNameInst->id );
		
		/* Save it off. */
		fsmTables->entry_by_region[pos++] = entryMapEl != 0 ? entryMapEl->value 
				: fsmTables->error_state;
	}
	
	return fsmTables;
}

void execAction( struct pda_run *pdaRun, LexAction *lexAction )
{
	for ( InlineList::Iter item = *lexAction->inlineList; item.lte(); item++ ) {
		switch ( item->type ) {
		case InlineItem::Text:
			assert(false);
			break;
		case InlineItem::LmSetActId:
			pdaRun->act = item->longestMatchPart->longestMatchId;
			break;
		case InlineItem::LmSetTokEnd:
			pdaRun->tokend = pdaRun->tokpref + ( pdaRun->p - pdaRun->start ) + 1;
			break;
		case InlineItem::LmInitTokStart:
			assert(false);
			break;
		case InlineItem::LmInitAct:
			pdaRun->act = 0;
			break;
		case InlineItem::LmSetTokStart:
			pdaRun->tokstart = pdaRun->p;
			break;
		case InlineItem::LmSwitch: {
			/* If the switch handles error then we also forced the error state. It
			 * will exist. */
			RegionImpl *region = RegionImpl::cast( item->longestMatch );
			if ( region->lmSwitchHandlesError && pdaRun->act == 0 ) {
				pdaRun->fsm_cs = pdaRun->fsm_tables->error_state;
			}
			else {
				for ( TokenInstanceListReg::Iter lmi = region->tokenInstanceList;
						lmi.lte(); lmi++ )
				{
					if ( lmi->inLmSelect && pdaRun->act == lmi->longestMatchId )
						pdaRun->matched_token = lmi->tokenDef->tdLangEl->id;
				}
			}
			pdaRun->return_result = true;
			pdaRun->skip_tokpref = true;
			break;
		}
		case InlineItem::LmOnLast: {
			TokenInstance *token = TokenInstance::cast( item->longestMatchPart );
			pdaRun->p += 1;
			pdaRun->tokend = pdaRun->tokpref + ( pdaRun->p - pdaRun->start );
			pdaRun->matched_token = token->tokenDef->tdLangEl->id;
			pdaRun->return_result = true;
			break;
		}
		case InlineItem::LmOnNext: {
			TokenInstance *token = TokenInstance::cast( item->longestMatchPart );
			pdaRun->tokend = pdaRun->tokpref + ( pdaRun->p - pdaRun->start );
			pdaRun->matched_token = token->tokenDef->tdLangEl->id;
			pdaRun->return_result = true;
			break;
		}
		case InlineItem::LmOnLagBehind: {
			TokenInstance *token = TokenInstance::cast( item->longestMatchPart );
			pdaRun->matched_token = token->tokenDef->tdLangEl->id;
			pdaRun->return_result = true;
			pdaRun->skip_tokpref = true;
			break;
		}
		default:
			assert(false);
			break;
		}
	}

	if ( lexAction->markType == MarkMark )
		pdaRun->mark[lexAction->markId] = pdaRun->p;
}

extern "C" void internalFsmExecute( struct pda_run *pdaRun, struct input_impl *inputStream )
{
	int _klen;
	unsigned int _trans;
	const long *_acts;
	unsigned int _nacts;
	const char *_keys;
		
	pdaRun->start = pdaRun->p;

	/* Init the token match to nothing (the sentinal). */
	pdaRun->matched_token = 0;

/*_resume:*/
	if ( pdaRun->fsm_cs == pdaRun->fsm_tables->error_state )
		goto out;

	if ( pdaRun->p == pdaRun->pe )
		goto out;

_loop_head:
	_acts = pdaRun->fsm_tables->actions + pdaRun->fsm_tables->from_state_actions[pdaRun->fsm_cs];
	_nacts = (unsigned int) *_acts++;
	while ( _nacts-- > 0 )
		execAction( pdaRun, pdaRun->fsm_tables->action_switch[*_acts++] );

	_keys = pdaRun->fsm_tables->trans_keys + pdaRun->fsm_tables->key_offsets[pdaRun->fsm_cs];
	_trans = pdaRun->fsm_tables->index_offsets[pdaRun->fsm_cs];

	_klen = pdaRun->fsm_tables->single_lengths[pdaRun->fsm_cs];
	if ( _klen > 0 ) {
		const char *_lower = _keys;
		const char *_mid;
		const char *_upper = _keys + _klen - 1;
		while (1) {
			if ( _upper < _lower )
				break;

			_mid = _lower + ((_upper-_lower) >> 1);
			if ( (*pdaRun->p) < *_mid )
				_upper = _mid - 1;
			else if ( (*pdaRun->p) > *_mid )
				_lower = _mid + 1;
			else {
				_trans += (_mid - _keys);
				goto _match;
			}
		}
		_keys += _klen;
		_trans += _klen;
	}

	_klen = pdaRun->fsm_tables->range_lengths[pdaRun->fsm_cs];
	if ( _klen > 0 ) {
		const char *_lower = _keys;
		const char *_mid;
		const char *_upper = _keys + (_klen<<1) - 2;
		while (1) {
			if ( _upper < _lower )
				break;

			_mid = _lower + (((_upper-_lower) >> 1) & ~1);
			if ( (*pdaRun->p) < _mid[0] )
				_upper = _mid - 2;
			else if ( (*pdaRun->p) > _mid[1] )
				_lower = _mid + 2;
			else {
				_trans += ((_mid - _keys)>>1);
				goto _match;
			}
		}
		_trans += _klen;
	}

_match:
	pdaRun->fsm_cs = pdaRun->fsm_tables->transTargsWI[_trans];

	if ( pdaRun->fsm_tables->transActionsWI[_trans] == 0 )
		goto _again;

	pdaRun->return_result = false;
	pdaRun->skip_tokpref = false;
	_acts = pdaRun->fsm_tables->actions + pdaRun->fsm_tables->transActionsWI[_trans];
	_nacts = (unsigned int) *_acts++;
	while ( _nacts-- > 0 )
		execAction( pdaRun, pdaRun->fsm_tables->action_switch[*_acts++] );
	if ( pdaRun->return_result ) {
		if ( pdaRun->skip_tokpref )
			goto skip_tokpref;
		goto final;
	}

_again:
	_acts = pdaRun->fsm_tables->actions + pdaRun->fsm_tables->to_state_actions[pdaRun->fsm_cs];
	_nacts = (unsigned int) *_acts++;
	while ( _nacts-- > 0 )
		execAction( pdaRun, pdaRun->fsm_tables->action_switch[*_acts++] );

	if ( pdaRun->fsm_cs == pdaRun->fsm_tables->error_state )
		goto out;

	if ( ++pdaRun->p != pdaRun->pe )
		goto _loop_head;
out:
	if ( pdaRun->scan_eof ) {
		pdaRun->return_result = false;
		pdaRun->skip_tokpref = false;
		_acts = pdaRun->fsm_tables->actions + pdaRun->fsm_tables->eof_actions[pdaRun->fsm_cs];
		_nacts = (unsigned int) *_acts++;

		if ( pdaRun->fsm_tables->eof_targs[pdaRun->fsm_cs] >= 0 )
			pdaRun->fsm_cs = pdaRun->fsm_tables->eof_targs[pdaRun->fsm_cs];

		while ( _nacts-- > 0 )
			execAction( pdaRun, pdaRun->fsm_tables->action_switch[*_acts++] );
		if ( pdaRun->return_result ) {
			if ( pdaRun->skip_tokpref )
				goto skip_tokpref;
			goto final;
		}
	}

final:

	if ( pdaRun->p != 0 )
		pdaRun->tokpref += pdaRun->p - pdaRun->start;
skip_tokpref:
	{}
}
